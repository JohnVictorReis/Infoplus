//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
//Importações principais                             //
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
const { setGlobalOptions } = require("firebase-functions/v2");
const { onRequest } = require("firebase-functions/v2/https");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

admin.initializeApp();

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
//Configuração global de instâncias                  //
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
setGlobalOptions({ maxInstances: 10 });

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
//Função HTTP para deletar um usuário (Admin)        //
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
exports.deletarUsuario = onRequest(async (req, res) => {
  if (req.method !== "POST") {
    return res.status(405).send("Método não permitido");
  }

  const { uid } = req.body;

  if (!uid) {
    return res.status(400).send("UID é obrigatório.");
  }

  try {
    await admin.auth().deleteUser(uid);
    return res
      .status(200)
      .json({ message: `Usuário com UID ${uid} excluído.` });
  } catch (error) {
    logger.error("Erro ao deletar usuário:", error);
    return res.status(500).json({ error: error.message });
  }
});

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
//Função para enviar notificação push ao aluno       //
//quando uma nova nota for adicionada                //
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//
exports.enviarNotificacaoNovaNota = onDocumentCreated(
  {
    region: "southamerica-east1", // Região ajustada para compatibilidade
    document: "users/{uid}/notificacoes/{notificacaoId}",
  },
  async (event) => {
    const snap = event.data;
    const context = event.params;
    const notaData = snap.data();
    const uid = context.uid;

    try {
      // Recuperando o token do Firestore
      const tokenDoc = await admin
        .firestore()
        .collection(`users/${uid}/fcmTokens`)
        .limit(1)  // Garantindo que só existe um token
        .get();

      // Se não existir token, gera um novo
      let token;
      if (tokenDoc.empty) {
        console.log(`Nenhum token encontrado para o usuário ${uid}, gerando um novo.`);
        
        // Gerar um novo token para o usuário
        const messaging = admin.messaging();
        token = await messaging.getToken();

        // Salvar o novo token para o usuário
        if (token) {
          await admin.firestore()
            .collection('users')
            .doc(uid)
            .collection('fcmTokens')
            .doc(token)  // Usando o token como ID para garantir que não haja duplicação
            .set({
              token: token,
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });
        }
      } else {
        // Se já existir, usaremos o token já salvo
        token = tokenDoc.docs[0].data().token;
        console.log(`Token encontrado para o usuário ${uid}`);
      }

      // Construindo a payload da notificação
      const payload = {
        notification: {
          title: "Nova nota cadastrada",
          body: notaData.mensagem || "Confira sua nova nota na plataforma",
          icon: "ic_stat_ic_notification",  // Ícone da notificação
          color: "#000000",  // Cor do ícone
          sound: "default",  // Som
          priority: "high",  // Prioridade
        },
        data: {
          click_action: 'FLUTTER_NOTIFICATION_CLICK', // Ação ao clicar
        },
      };

      // Enviando a notificação para o token único
      const response = await admin.messaging().sendToDevice(token, payload, {
        priority: "high",
      });

      console.log(`Notificação enviada para o usuário ${uid}`);
      console.log("Resposta do FCM:", response);
    } catch (error) {
      console.error("Erro ao enviar notificação:", error);
    }
  }
);

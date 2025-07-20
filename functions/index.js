const { setGlobalOptions } = require("firebase-functions/v2");
const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

admin.initializeApp();

setGlobalOptions({ maxInstances: 10 });

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
    return res.status(200).json({ message: `Usuário com UID ${uid} excluído.` });
  } catch (error) {
    logger.error("Erro ao deletar usuário:", error);
    return res.status(500).json({ error: error.message });
  }
});

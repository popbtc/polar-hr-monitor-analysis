import express from "express";
import { WebSocketServer } from "ws";
import http from "http";

const app = express();
const server = http.createServer(app);
const wss = new WebSocketServer({ server });

wss.on("connection", ws => {
  console.log("🔗 Client connected");

  ws.on("message", message => {
    console.log("📩", message.toString());
    // ส่งต่อข้อความไปทุก client (รวมทีวี)
    wss.clients.forEach(client => {
      if (client.readyState === 1) {
        client.send(message.toString());
      }
    });
  });

  ws.on("close", () => console.log("❌ Client disconnected"));
});

app.get("/", (req, res) => res.send("✅ Polar HR WebSocket Server running"));

const port = process.env.PORT || 10000;
server.listen(port, () => console.log(`🚀 Listening on port ${port}`));

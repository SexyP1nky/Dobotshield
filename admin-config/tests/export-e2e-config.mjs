import fs from "node:fs";
import path from "node:path";
import vm from "node:vm";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const adminRoot = path.resolve(here, "..");
const window = {};
const context = vm.createContext({ URL, window });

for (const filename of ["config-schema.js", "validators.js", "formatters.js"]) {
  vm.runInContext(fs.readFileSync(path.join(adminRoot, "scripts", filename), "utf8"), context, { filename });
}

const admin = window.DoBotAdmin;
const config = {
  ...admin.getDefaultConfig(),
  targetUrl: "http://lab_e2e_backend:8080",
  proxyPort: ":8088",
  httpMode: "true",
  enableWaf: "true",
  wafMode: "block",
  enableResponseInspection: "true",
  enableRateLimit: "true",
  rateLimit: "1000",
  burstLimit: "2000",
  maxConns: "200",
  certFile: "",
  keyFile: "",
  trustedProxies: "127.0.0.1,::1",
  enableTraining: "true",
  trainingLogFile: "/logs/e2e-training.jsonl"
};

const validation = admin.validateConfig(config);
if (!validation.isValid) {
  throw new Error(`configuracao E2E invalida: ${JSON.stringify(validation.errors)}`);
}

process.stdout.write(admin.buildDotEnv(config) + "\n");

import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import vm from "node:vm";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const adminRoot = path.resolve(here, "..");
const window = {};
const context = vm.createContext({ URL, window });

for (const filename of ["config-schema.js", "validators.js", "formatters.js"]) {
  const source = fs.readFileSync(path.join(adminRoot, "scripts", filename), "utf8");
  vm.runInContext(source, context, { filename });
}

const admin = window.DoBotAdmin;
const defaults = admin.getDefaultConfig();
const expectedEnvs = [
  "TARGET_URL",
  "PROXY_PORT",
  "HTTP_MODE",
  "ENABLE_WAF",
  "WAF_MODE",
  "ENABLE_RESPONSE_INSPECTION",
  "ENABLE_RATE_LIMIT",
  "RATE_LIMIT",
  "BURST_LIMIT",
  "MAX_CONNS",
  "MAX_TRACKED_IPS",
  "MAX_BODY_SIZE",
  "RESPONSE_INSPECTION_LIMIT",
  "CERT_FILE",
  "KEY_FILE",
  "TRUSTED_PROXIES",
  "INSECURE_SKIP_VERIFY",
  "CONTENT_SECURITY_POLICY",
  "WAF_ALLOWLIST",
  "BLOCKED_IPS",
  "RATE_LIMIT_STATE_FILE",
  "TRAINING_MODE",
  "TRAINING_LOG_FILE"
];

assert.deepEqual(
  Array.from(admin.CONFIG_FIELDS, (field) => field.env),
  expectedEnvs,
  "o schema deve cobrir todas as variaveis aceitas pelo binario"
);
assert.equal(admin.validateConfig(defaults).isValid, true, "os valores padrao devem ser validos");

const dotenv = admin.buildDotEnv({
  ...defaults,
  contentSecurityPolicy: "default-src 'self'",
  blockedIps: "192.0.2.10,10.0.0.0/8"
});
for (const env of expectedEnvs) {
  assert.match(dotenv, new RegExp(`^${env}=`, "m"), `${env} deve aparecer no .env`);
}
assert.match(dotenv, /^CONTENT_SECURITY_POLICY="default-src 'self'"$/m);
assert.match(dotenv, /^BLOCKED_IPS="192\.0\.2\.10,10\.0\.0\.0\/8"$/m);

const sampleConfig = {
  ...defaults,
  targetUrl: "https://backend.example:9443",
  proxyPort: "127.0.0.1:8443",
  httpMode: "true",
  wafMode: "monitor",
  enableResponseInspection: "false",
  enableRateLimit: "false",
  rateLimit: "12.5",
  burstLimit: "25",
  maxConns: "15",
  maxTrackedIps: "750",
  maxBodySize: "2097152",
  responseInspectionLimit: "524288",
  certFile: "tls/cert.pem",
  keyFile: "tls/key.pem",
  trustedProxies: "192.0.2.10, 2001:db8::1",
  insecureSkipVerify: "true",
  contentSecurityPolicy: "default-src 'self'",
  wafAllowlist: "SQLi:/search",
  blockedIps: "198.51.100.10, 203.0.113.0/24",
  rateLimitStateFile: "state/rate.json",
  enableTraining: "false",
  trainingLogFile: "audit/events.jsonl"
};
const generatedDotEnv = admin.buildDotEnv(sampleConfig);
const parsedDotEnv = Object.fromEntries(
  generatedDotEnv
    .split(/\r?\n/)
    .filter((line) => line && !line.startsWith("#"))
    .map((line) => {
      const separator = line.indexOf("=");
      return [line.slice(0, separator), JSON.parse(line.slice(separator + 1))];
    })
);
const normalizedSample = admin.normalizeConfig(sampleConfig);
for (const field of admin.CONFIG_FIELDS) {
  assert.equal(parsedDotEnv[field.env], normalizedSample[field.id], `${field.env} deve preservar o valor configurado`);
}
assert.match(admin.buildCommand(sampleConfig, "powershell"), /\$env:CONTENT_SECURITY_POLICY = 'default-src ''self'''/);
assert.match(admin.buildCommand(sampleConfig, "bash"), /export CONTENT_SECURITY_POLICY='default-src '\\''self'\\'''/);

assert.match(admin.buildCommand(defaults, "powershell"), /^# Acesso: https:\/\/localhost:443/m);
assert.match(admin.buildCommand({ ...defaults, httpMode: "true", proxyPort: ":8080" }, "bash"), /^# Acesso: http:\/\/localhost:8080/m);

const httpWithoutCerts = { ...defaults, httpMode: "true", certFile: "", keyFile: "" };
assert.equal(admin.validateConfig(httpWithoutCerts).isValid, true, "HTTP puro nao usa certificado");
const httpsWithoutCerts = { ...defaults, certFile: "", keyFile: "" };
assert.equal(admin.validateConfig(httpsWithoutCerts).isValid, false, "HTTPS exige certificado e chave");

for (const [field, value] of [
  ["targetUrl", "ftp://example.test"],
  ["proxyPort", ":70000"],
  ["rateLimit", "0"],
  ["burstLimit", "1.5"],
  ["maxBodySize", "100"],
  ["trustedProxies", "999.1.1.1"],
  ["blockedIps", "not-an-ip"],
  ["blockedIps", "::::"],
  ["blockedIps", "192.168.001.1"]
]) {
  assert.equal(admin.validateField(field, value).isValid, false, `${field} deve rejeitar ${value}`);
}

for (const value of ["192.0.2.1", "10.0.0.0/8", "2001:db8::1", "2001:db8::/32"]) {
  assert.equal(admin.validateField("blockedIps", value).isValid, true, `blockedIps deve aceitar ${value}`);
}

const html = fs.readFileSync(path.join(adminRoot, "index.html"), "utf8");
const checkboxFields = new Set([
  "httpMode",
  "enableWaf",
  "enableResponseInspection",
  "enableRateLimit",
  "enableTraining",
  "insecureSkipVerify"
]);
for (const field of admin.CONFIG_FIELDS) {
  assert.equal((html.match(new RegExp(`id="${field.id}"`, "g")) || []).length, 1, `${field.id} deve existir uma vez`);
  if (!checkboxFields.has(field.id)) {
    assert.equal((html.match(new RegExp(`data-error-for="${field.id}"`, "g")) || []).length, 1, `${field.id} deve ter saida de erro`);
  }
}

console.log(`admin-config: ${admin.CONFIG_FIELDS.length} campos validados`);

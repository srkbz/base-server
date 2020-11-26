local config = import '../config.json';
local u = import 'utils.libsonnet';

u.CertIssuer("letsencrypt-prod", {
    server: 'https://acme-v02.api.letsencrypt.org/directory',
    email: 'hello@sirikon.me'
})
+

u.App("buletina-demo", {
    domain: "buletina-demo.srk.bz",
    certIssuer: 'letsencrypt-prod',
    image: "sirikon/buletina:1.0.0_20201126_231117",
    port: 80,
    env: {
        BULETINA_PORT: 80,
        BULETINA_BASE_URL: "https://buletina-demo.srk.bz",
        BULETINA_DATABASE_URL: config.buletinaDatabaseUrl,
        BULETINA_JWT_SECRET: "asdfasdfasdfasdfasdf",
        BULETINA_SMTP_SERVER: "asdfasdfasdfasdfasdf",
        BULETINA_SMTP_USERNAME: "asdfasdfasdfasdfasdf",
        BULETINA_SMTP_PASSWORD: "asdfasdfasdfasdfasdf",
        BULETINA_SMTP_SENDER: "asdfasdfasdfasdfasdf"
    }
})
+

u.App("nginx-test", {
    domain: 'kube.master.srk.bz',
    certIssuer: 'letsencrypt-prod',
    image: 'nginx:1.7.9',
    port: 80
})

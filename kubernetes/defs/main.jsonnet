local config = import '../config.json';
local u = import 'utils.libsonnet';
{}

+u.CertIssuer("letsencrypt-prod", {
    server: 'https://acme-v02.api.letsencrypt.org/directory',
    email: 'hello@sirikon.me'
})

+u.App("buletina-bilbaoswcraft", {
    domain: "bilbao.softwarecrafters.org",
    certIssuer: 'letsencrypt-prod',
    image: "sirikon/srkbz-buletina-custom:bilbaoswcraft_20201203_191040",
    port: 80,
    env: {
        BULETINA_PORT: 80,
        BULETINA_BASE_URL: "https://bilbao.softwarecrafters.org"
    } + config.buletina_bilbaoswcraft
})

// +u.App("nginx-test", {
//     domain: 'kube.master.srk.bz',
//     certIssuer: 'letsencrypt-prod',
//     image: 'nginx:1.7.9',
//     port: 80
// })

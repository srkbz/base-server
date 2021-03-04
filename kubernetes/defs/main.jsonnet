local config = import '../config.json';
local u = import 'utils.libsonnet';
{}

+u.DashboardUser()

+u.CertIssuer("letsencrypt-prod", {
    server: 'https://acme-v02.api.letsencrypt.org/directory',
    email: 'hello@sirikon.me'
})

+u.App("fathom", {
    domain: "fathom.srk.bz",
    certIssuer: 'letsencrypt-prod',
    image: "usefathom/fathom",
    port: 80,
    env: {
		FATHOM_SERVER_ADDR: "0.0.0.0:80",
		FATHOM_DATABASE_DRIVER: "postgres",
	} + config.fathom
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

+u.App("apt-repository", {
    domain: 'apt.srk.bz',
    certIssuer: 'letsencrypt-prod',
    image: 'sirikon/apt-repository:20210304_015145',
    port: 80,
	env: config.apt_repository,
	volumes: {
		'data': '/data'
	},
})

// +u.App("nginx-test", {
//     domain: 'kube.master.srk.bz',
//     certIssuer: 'letsencrypt-prod',
//     image: 'nginx:1.19',
//     port: 80,
// 	volumes: {
// 		'html': '/usr/share/nginx/html'
// 	},
// })

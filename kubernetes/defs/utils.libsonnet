local keyValues(obj) = std.map(function(x) { key: x, value: obj[x] }, std.objectFields(obj));

local AppLabels(name) = {
    app: name
};

local Deployment(name, config) = {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
        name: name + '-deployment',
        labels: AppLabels(name)
    },
    spec: {
        replicas: 1,
        selector: { matchLabels: AppLabels(name) },
        template: {
            metadata: { labels: AppLabels(name) },
            spec: {
                containers: [{
                    name: name,
                    image: config.image,
                    ports: [{
                        containerPort: config.port
                    }],
                    env: [
                        { name: e.key, value: std.toString(e.value) },
                        for e in keyValues(if std.objectHas(config, 'env') then config.env else {})
                    ]
                }],
            },
        },
    },
};

local Service(name, config) = {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
        name: name + '-service',
    },
    spec: {
        selector: AppLabels(name),
        ports: [{
            port: config.port,
            targetPort: config.port
        }],
    },
};

local Certificate(name, config) = {
    apiVersion: 'cert-manager.io/v1',
    kind: 'Certificate',
    metadata: {
        name: name + '-certificate',
    },
    spec: {
        secretName: name + '-certificate-tls',
        issuerRef: {
            name: config.certIssuer,
            kind: 'ClusterIssuer'
        },
        commonName: config.domain,
        dnsNames: [config.domain],
    },
};

local Ingress(name, config) = {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'Ingress',
    metadata: {
        name: name + '-ingress',
        annotations: {
            ['kubernetes.io/ingress.class']: 'traefik',
            ['cert-manager.io/cluster-issuer']: config.certIssuer,
            ['traefik.ingress.kubernetes.io/redirect-entry-point']: 'https',
        },
    },
    spec: {
        rules: [{
            host: config.domain,
            http: {
                paths: [{
                    path: '/',
                    pathType: 'Prefix',
                    backend: {
                        service: {
                            name: name + '-service',
                            port: {
                                number: config.port
                            }
                        }
                    }
                }]
            }
        }],
        tls: [{
            hosts: [config.domain],
            secretName: name + '-certificate-tls'
        }]
    }
};

local ClusterIssuer(name, config) = {
    apiVersion: 'cert-manager.io/v1',
    kind: 'ClusterIssuer',
    metadata: {
        name: name
    },
    spec: {
        acme: {
            server: config.server,
            email: config.email,
            privateKeySecretRef: {
                name: name
            },
            solvers: [{
                http01: {
                    ingress: {
                        class: 'traefik'
                    }
                }
            }]
        }
    }
};

{
    App(name, config):: {
        ['apps/' + name + '/' + name + '-deployment.json']: Deployment(name, config),
        ['apps/' + name + '/' + name + '-service.json']: Service(name, config),
        ['apps/' + name + '/' + name + '-certificate.json']: Certificate(name, config),
        ['apps/' + name + '/' + name + '-ingress.json']: Ingress(name, config),
    },
    CertIssuer(name, config):: {
        ['cert-manager/issuers/' + name + '.json']: ClusterIssuer(name, config),
    },
}

const http = require('http');

function testUrl(port) {
    const options = {
        hostname: 'localhost',
        port: port,
        path: '/api/config/site-modules?userRole=SUPERADMINISTRADOR',
        method: 'GET',
        headers: {
            'X-User-Role': 'SUPERADMINISTRADOR'
        }
    };

    const req = http.request(options, (res) => {
        let data = '';
        res.on('data', (chunk) => { data += chunk; });
        res.on('end', () => {
            console.log(`Port ${port} HTTP status:`, res.statusCode);
            console.log(`Port ${port} Body length:`, data.length);
            try {
                const parsed = JSON.parse(data);
                console.log(`Port ${port} Modules count:`, parsed.modules?.length);
                console.log(`Port ${port} Masters count:`, parsed.masters?.length);
                if (parsed.message) console.log(`Port ${port} Message:`, parsed.message);
                if (parsed.error) console.log(`Port ${port} Error detail:`, parsed.error);
            } catch (e) {
                console.log(`Port ${port} Raw response:`, data.substring(0, 200));
            }
        });
    });

    req.on('error', (e) => {
        console.error(`Port ${port} Error:`, e.message);
    });

    req.end();
}

testUrl(3000);
testUrl(3001);

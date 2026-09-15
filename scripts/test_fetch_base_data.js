const http = require('http');

function testEndpoint(path) {
    return new Promise((resolve, reject) => {
        http.get('http://localhost:3001' + path, (res) => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => {
                try {
                    const parsed = JSON.parse(data);
                    const summary = {};
                    if (res.statusCode === 200) {
                        for (const key of Object.keys(parsed)) {
                            if (Array.isArray(parsed[key])) {
                                summary[key] = parsed[key].length;
                            } else {
                                summary[key] = typeof parsed[key];
                            }
                        }
                    }
                    resolve({ status: res.statusCode, summary, raw: data.substring(0, 300) });
                } catch (e) {
                    resolve({ status: res.statusCode, error: e.message, raw: data.substring(0, 300) });
                }
            });
        }).on('error', err => reject(err));
    });
}

async function main() {
    console.log("=== PROBANDO /api/quotations/base-data ===");
    const res1 = await testEndpoint('/api/quotations/base-data');
    console.log("STATUS:", res1.status);
    console.log("RESUMEN DE CATALOGOS:", JSON.stringify(res1.summary, null, 2));

    console.log("\n=== PROBANDO /api/invoices/base-data ===");
    const res2 = await testEndpoint('/api/invoices/base-data');
    console.log("STATUS:", res2.status);
    console.log("RESUMEN DE CATALOGOS:", JSON.stringify(res2.summary, null, 2));
}

main().catch(console.error);

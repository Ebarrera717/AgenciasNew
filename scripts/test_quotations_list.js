const http = require('http');

http.get('http://localhost:3001/api/quotations/list', (res) => {
    let data = '';
    res.on('data', chunk => data += chunk);
    res.on('end', () => {
        console.log("STATUS:", res.statusCode);
        console.log("RESPONSE:", data);
    });
}).on('error', console.error);

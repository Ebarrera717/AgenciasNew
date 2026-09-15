const http = require('http');

async function testPostQuotation() {
    const payload = JSON.stringify({
        clientId: "11",
        clientDocument: "79898456",
        branchId: "1",
        branchCode: "OFP",
        sellerId: "1",
        sellerCode: "OFP",
        ticketPrinterId: "1",
        ticketPrinterCode: "01E",
        currency: "COP",
        exchangeRate: 1,
        commissionPercentage: 10,
        comisionTotalPercentage: 10,
        comisionFreelancePercentage: 0,
        comisionPropiaPercentage: 10,
        chargesAndTaxes: 180000,
        totalAmount: 180000,
        items: [{
            productId: "7",
            productCode: "HTL",
            quantity: 1,
            price: 180000,
            cost: 0,
            providerId: "1",
            providerCode: "COLAEREO",
            prestadoraId: "",
            checkIn: "",
            checkOut: "",
            paxAdults: 1,
            paxChildren: 0,
            destination: "",
            serviceType: "",
            reservationCode: "",
            mainTaxId: "1",
            appliedTaxes: [],
            variables: [],
            passengers: [{ name: "EDUARDO BARRERA", document: "79898456" }]
        }],
        state: "Nuevo"
    });

    const req = http.request({
        hostname: 'localhost',
        port: 3001,
        path: '/api/quotations',
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Content-Length': Buffer.byteLength(payload),
            'X-User-Id': '1'
        }
    }, (res) => {
        let data = '';
        res.on('data', chunk => data += chunk);
        res.on('end', () => {
            console.log("STATUS:", res.statusCode);
            console.log("RESPONSE:", data);
        });
    });

    req.on('error', (e) => {
        console.error("HTTP ERROR:", e.message);
    });

    req.write(payload);
    req.end();
}

testPostQuotation();


var totalAmount = 100000;
var mintedAmount = 0;
var interval;

var batchMintERC721 = function () {

    console.log("Tickets left to mint: " + (totalAmount - mintedAmount));

    var params = {
      "from": "0x2e16f253e0a3b544f7e755a8d904976adaea7833",
      "to": "0xD32F8de3d5DAB3A61c3c58046E086065FEC4168c",
      "gas": "0x7A1200",
      "gasPrice": "0x37E11D600",
      "data": "0x0e583dd20000000000000000000000002e16f253e0a3b544f7e755a8d904976adaea78330000000000000000000000000000000000000000000000000000000000000030"
    };

    eth.sendTransaction(params);
 
    mintedAmount += 50;
    if (mintedAmount > totalAmount) {
        clearInterval(interval);
    }
}

var start = function () {
    interval = setInterval(batchMintERC721, 45000);
}

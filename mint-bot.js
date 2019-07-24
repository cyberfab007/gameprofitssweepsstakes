
var totalAmount = 100000;
var mintedAmount = 0;
var batchAmount = 20;
var batchAmountParam;
var fromRoot = '2e16f253e0a3B544f7e755A8d904976adAEa7833';
var fromParam = '000000000000000000000000' + fromRoot.toLowerCase();
// var to = "0xD32F8de3d5DAB3A61c3c58046E086065FEC4168c";
var to = "0x6E4610109dD9921e2d23312669f4521d5D5A45f6";
// var gas = "0x7A1200"; // 8M
var gas = "0x14FB180"; // 22M
var gasPrice = "0x37E11D600"; // 15B

var paramsBalanceOf = {
  "to": to,
  "data": "0x70a08231" + fromParam
};

var paramsMintAmount;
var intervalMs = 40000;
var interval;

var callbackMintAmount = function (error, result) {
  if (error) console.error(error);
  else console.log("Tx hash: " + result);
}

var batchMint = function () {
    
    var balance = eth.call(paramsBalanceOf);
    
    console.log(new Date() + "\tBalance of " + fromRoot + ": " + parseInt(balance) + "\tTickets left to mint: " + (totalAmount - mintedAmount));

    eth.sendTransaction(paramsMintAmount, callbackMintAmount);

    mintedAmount += batchAmount;
    if (mintedAmount > totalAmount) {
        clearInterval(interval);
    }
}

var start = function (_totalAmount, _batchAmount, _interval) {
    totalAmount = _totalAmount ? _totalAmount : totalAmount;
    batchAmount = _batchAmount ? _batchAmount : batchAmount;
    if (batchAmount < 0 || batchAmount > 255) {
        console.log("Set 0 <= _batchAmount <= 50");
        return;
    }
    batchAmountParam = '00000000000000000000000000000000000000000000000000000000000000' + (batchAmount < 17 ? '0' : '') + batchAmount.toString(16);
    paramsMintAmount = {
      "from": '0x' + fromRoot,
      "to": to,
      "gas": gas,
      "gasPrice": gasPrice,
      "data": "0x0e583dd2" + fromParam + batchAmountParam
    };
    intervalMs = _interval ? _interval * 1000 : intervalMs;
    console.log("Started minting " + totalAmount + " Tickets at rate " + batchAmount + " Tickets per " + (intervalMs / 1000) + " seconds");
    interval = setInterval(batchMint, intervalMs);
}


var totalAmount = 100000;
var mintedAmount = 0;
var batchAmount = 20;
var batchAmountParam = batchAmount.toString(16).padStart(64, '0');
var fromRoot = '2e16f253e0a3B544f7e755A8d904976adAEa7833'
var fromParam = fromRoot.toLowerCase().padStart(64, '0');

var paramsBalanceOf = {
  "to": "0xD32F8de3d5DAB3A61c3c58046E086065FEC4168c",
  "data": "0x70a08231" + fromParam
};

var paramsMintAmount = {
  "from": '0x' + fromRoot,
  "to": "0xD32F8de3d5DAB3A61c3c58046E086065FEC4168c",
  "gas": "0x7A1200",
  "gasPrice": "0x37E11D600",
  "data": "0x0e583dd2" + fromParam + batchAmountParam
};

var intervalMs = 40000;
var interval;

var handleReceipt = (error, receipt) => {
  if (error) console.error(error);
  else console.log(receipt);
}

var batchMint = function () {
    
    var balance = eth.call(paramsBalanceOf);
    
    console.log(new Date() + "\tBalance of " + fromRoot + ": " + balance + ",\tTickets left to mint: " + (totalAmount - mintedAmount));

    eth.sendTransaction(paramsMintAmount, handleReceipt);

    mintedAmount += amountDec;
    if (mintedAmount > totalAmount) {
        clearInterval(interval);
    }
}

var start = function (_totalAmount, _batchAmount, _interval) {
    totalAmount = _totalAmount;
    batchAmount = _batchAmount;
    intervalMs = _interval * 1000;
    console.log("Started minting " + totalAmount + " Tickets at rate " + batchAmountDec + " Tickets per " + (intervalMs / 1000) + " seconds");
    interval = setInterval(batchMint, intervalMs);
}

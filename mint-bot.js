
var totalAmount = 100000;
var mintedAmount = 0;
var batchAmountDec = 20;
var batchAmountHex = batchDec.toString(16);
var batchAmountParam = batchHex.padStart(64, '0');
var fromRoot = '2E16f253e0a3b544f7e755A8d904976adAEa7833'
var fromParam = fromRoot.toLowerCase().padStart(64, '0');

var params = {
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

var batchMintERC721 = function () {
    console.log("Tickets left to mint: " + (totalAmount - mintedAmount));

    eth.sendTransaction(params, handleReceipt);

    mintedAmount += amountDec;
    if (mintedAmount > totalAmount) {
        clearInterval(interval);
    }
}

var start = function () {
    console.log("Started minting " + totalAmount + " Tickets at rate " + batchAmountDec + " Tickets per " + (intervalMs / 1000) + " seconds");
    interval = setInterval(batchMintERC721, intervalMs);
}

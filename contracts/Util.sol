pragma solidity ^0.5.0;

library Util {

    function bytes2bytes32(bytes memory arg, uint offset) public pure returns (bytes32) {
        bytes32 out;
        for (uint i = 0; i < 32; i++) {
            out |= bytes32(arg[offset + i] & 0xFF) >> (i * 8);
        }
        return out;
    }

    function uint2str(uint arg) public pure returns (string memory) {
        if (arg == 0) {
            return "0";
        }
        uint j = arg;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (arg != 0) {
            bstr[k--] = byte(uint8(48 + arg % 10));
            arg /= 10;
        }
        return string(bstr);
    }

    function addr2str(address arg) public pure returns (string memory) {
        bytes32 value = bytes32(uint256(arg));
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(42);
        str[0] = '0';
        str[1] = 'x';
        for (uint i = 0; i < 20; i++) {
            str[2+i*2] = alphabet[uint(uint8(value[i + 12] >> 4))];
            str[3+i*2] = alphabet[uint(uint8(value[i + 12] & 0x0f))];
        }
        return string(str);
    }
}

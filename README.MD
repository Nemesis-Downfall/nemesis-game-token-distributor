##### Nemesis Downfall Game Rewards Distributor

**Testnet:** 0xEE1615171FBC7e478d1EC4016Ac9E4Cc491Ad6c5 [https://testnet.bscscan.com/address/0xee1615171fbc7e478d1ec4016ac9e4cc491ad6c5#code](https://testnet.bscscan.com/address/0xee1615171fbc7e478d1ec4016ac9e4cc491ad6c5#code)

For tokens to be distributed to winners of the game, they must sign a message hash which produces a signature, and have this signature, along with bits of the message, published to the API which would use a wallet that has been granted distributor status to send this signature and message bits to the smart contract which in turn would lease out the tokens. This message hash would be a bytes32 data type that is generated through the packing of certain variables (you should do this using a function that models or mimics Solidity's `abi.encodePacked`) which is in turn passed through a function that models Solidity's `keccak256`. The examples below should help simplify this.


* **Generating the byte message:**

The message to be hashed and signed must be of the `bytes` data type. Do this using a function or library that models Solidity's `abi.encodePacked`. The data to be packed include - a random string (to be used later), "Nemesis_Downfall", a nonce that's unique for every call per user, the actual reward (in wei). To generate this message, you'd do something like this:

*encode_packed(RANDOM_STRING, "Nemesis_Downfall", UNIQUE_NONCE, REWARD_IN_WEI)*

To fetch the next nonce for the player, call the `nextNonce` function of the distribution smart contract, passing the player's wallet address as an argument. Do it like so - `contract.nextNonce(PLAYER_WALLET_ADDRESS)`. You may then pass the result as the third argument used in generating the byte message.


* **Hashing the generated byte:**

The byte gotten from the previous step should be passed as an argument to a function that mimics Solidity's `keccak256` algorithm.

*keccak_256(GENERATED_BYTE)*
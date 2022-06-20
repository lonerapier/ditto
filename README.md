# DITTO

Ditto is a metapmorphic contract mechanism coined initially by [@0age's](https://twitter.com/z0age) [metamorphic](https://github.com/0age/metamorphic) contracts. They are absolutely mind-blowing, please check that out.

This has also been attempted by [@ricmoo's](https://github.com/ricmoo) [wisp](https://blog.ricmoo.com/wisps-the-magical-world-of-create2-5c2177027604) contracts.

```javascript
/*
 * 			⠀⠀⠀⢠⡜⠛⠛⠿⣤⠀⠀⣤⡼⠿⠿⢧⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * 			⠀⣀⡶⠎⠁⠀⠀⠀⠉⠶⠶⠉⠁⠀⠀⠈⠹⢆⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * 			⣀⡿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠶⠶⠶⠶⣆⡀⠀⠀⠀⠀
 * 			⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢣⡄⠀⠀⠀
 * 			⠛⣧⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀
 * 			⠀⠛⣧⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠿⠀⠀⠀⠀⢠⡼⠃⠀⠀
 * 			⠀⠀⠿⢇⡀⠀⠀⠀⠀⠀⠀⠀⠰⠶⠶⢆⣀⣀⣀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀
 * 			⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠉⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀
 * 			⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀
 * 			⠀⠀⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢣⣤
 * 			⠀⣶⡏⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿
 * 			⠀⠿⣇⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⣀⣀⣀⠀⠀⠀⠀⢀⣀⣸⠿
 * 			⠀⠀⠙⢳⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⡞⠛⠛⠛⠛⠛⠛⣶⣶⣶⣶⡞⠛⠃⠀
 */
```

This repo includes my own implmentation of this concept. So, the concept of ditto contracts are what is expected from the pokemon, i.e. taking the shape of new pokemons without anyone realizing what it was previously.

So, in terms of smart contracts, this utilises the pre-deterministic address of `create2` opcode and redeploying new implementations at the same address with the same initialization code.

For example, a ditto contract can initially be deployed with any implementation but just have to be *selfdestructable*, ditto will be able to copy the bytecode of the contract and take its shape. To take another contract's shape, ditto will selfdestruct itself and just copy another contract's bytecode as the initialization code is pre-deterministic.

The initialization bytecode follows these steps:

1. `staticcall` factory contract to get implementation address
2. get implementation contract `codesize`
3. copies code of implementation contract

## Ditto Initialization Code Explainer


1. set up for `staticcall`

```bash
0000    3D  RETURNDATASIZE
0001    60  PUSH1 0x32
0003    3D  RETURNDATASIZE
0004    60  PUSH1 0x04
0006    60  PUSH1 0x1c
0008    33  CALLER
0009    5A  GAS

STACK:
0000: gas		(gas)
0001: caller		(caller)
0002: 28		(memory offset)
0003: 4			(memory size)
0004: 0			(returndata offset)
0005: 0x32		(returndata size)
0006: 0
```

2. store `getImplementation` function sig which'll be called from ditto contract.

```bash
000A    63  PUSH4 0xaaf10f42
000F    3D  RETURNDATASIZE
0010    52  MSTORE

STACK:
0000: gas		(gas)
0001: caller		(caller)
0002: 28		(memory offset)
0003: 4			(memory size)
0004: 0			(returndata offset)
0005: 0x32		(returndata size)
0006: 0

MEMORY:
0000: 0xaaf10f42	(function sig)
```

3. Perform `staticcall` and get implementation address

```bash
0011    FA  STATICCALL
STACK:
0000: 1			(success)
0001: 0

MEMORY:
0000: address
```

4. load address to stack

```bash
0012    15  ISZERO
0013    81  DUP2
0014    51  MLOAD

STACK:
0000: address			(implementation address)
0001: 1				(success)
0000: 0

MEMORY:
0000: address
```

5. get codesize

```bash
0015    80  DUP1
0016    3B  EXTCODESIZE
0017    80  DUP1

STACK:
0000: size			(contract size)
0001: size			(contract size)
0002: address			(implementation address)
0003: 1
0004: 0

MEMORY:
0000: address
```

6. set up for copying implementaion's code

```bash
0018    93  SWAP4
0019    80  DUP1
001A    91  SWAP2
001B    92  SWAP3

STACK:
0000: address			(address)
0001: 0				(dest offset)
0002: 0				(offset)
0003: size			(size)
0004: 1
0005: size
```

7. copy the code to memory

```bash
001C    3C  EXTCODECOPY
STACK:
0001: 1
0002: size

MEMORY:
0000: code

001D    F3  *RETURN
```

## Acknowledgements

- [**Metamorphic**](https://github.com/0age/metamorphic)
- [femplate](https://github.com/abigger87/femplate)
- [foundry](https://github.com/foundry-rs/foundry)

## Disclaimer

*These smart contracts are being provided as is. No guarantee, representation or warranty is being made, express or implied, as to the safety or correctness of the user interface or the smart contracts. They have not been audited and as such there can be no assurance they will work as intended, and users may experience delays, failures, errors, omissions, loss of transmitted information or loss of funds. The creators are not liable for any of the foregoing. Users should proceed with caution and use at their own risk.*

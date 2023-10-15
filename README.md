test for Weth contract.

make sure you install foundry

clone this project 
`git clone git@github.com:Dennnnny/test-for-weth.git`

then use 
`forge test` to check the result
or `forge test -vvvv` to see more details

if after you clone this porject
and you can not run test 
maybe you could try to remove lib and re-install them

for me this works:
```
rmdir lib/forge-std lib/openzeppelin-contracts
forge install openzeppelin/openzeppelin-contracts foundry-rs/forge-std --no-commit
```

thanks

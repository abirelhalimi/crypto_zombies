pragma solidity >=0.5.0 <0.6.0; //version of the Solidity compiler that should be used - we can specify a range

contract ZombieFactory {

    /* events are a way for the contract to tell the front-end that something happened on the blockchain
       the app frontend can be listening for certain events to take action when they happen
    */
    event NewZombie(uint zombieId, string name, uint dna);
    // State variables are permanently stored in contract storage. They're written to the Ethereum blockchain
    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;

    struct Zombie {
        string name;
        uint dna;
    }

    // an array of structs : useful for storing structured data in the contract
    Zombie[] public zombies;

    /* The ethereum blockchain is made up of accounts
       Each account has an address
       the address is owned by a specific user or a smart contract
    */
    mapping(uint => address) public zombieToOwner; //mapping is key-value store for storing data
    mapping(address => uint) ownerZombieCount;

    /* functions are public by default, which means that anyone or any other contract can call and execute them
       which can make your contract vulnerable to attacks
       A good practice is to always make your functions private unless you need them to be public
    */
    /* function execution always needs to start with an external caller.
       A contract will just sit on the blockchain doing nothing until someone calls one of its functions.
       So there will always be a msg.sender
    */
    // internal : same as private, except that it's also accessible to contracts that inherit from this contract
    // external : same as public, except that these functions can only be called outside the contract
    // they can't be called by other functions inside the contract
    function _createZombie(string memory _name, uint _dna) internal {
        uint id = zombies.push(Zombie(_name, _dna)) - 1;
        /* msg.sender is a global variable that refers to the address of the person or smart contract
           who called the current function
           msg.sender gives us the security of the Ethereum blockchain since the only way to modify someone else's
           data would be to steal their private key
        */
        zombieToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender]++;
        // this is how we tell our front-end that something happened. We emit the event previously created
        emit NewZombie(id, _name, _dna);
    }

    // view functions : only viewing data but not modifying it, they don't change state
    function _generateRandomDna(string memory _str) private view returns (uint) {
        /* keccak256 is version of sha3 builtin in ethereum
           it maps an input into a random 256-bit hexadecimal number
           it expects a single parameter of type bytes
           you can use abi.encodePacked on a string to get the bytes
           ! beware this is insecure but it's okay for this use case
        */
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus;
    }

    function createRandomZombie(string memory _name) public {
        // the function will return an error and stop executing if required conditions are not met
        require(ownerZombieCount[msg.sender] == 0);
        uint randDna = _generateRandomDna(_name);
        randDna = randDna - randDna % 100;
        _createZombie(_name, randDna);
    }

    /* Side Notes
    ** -> Solidity doesn't have native string comparison
    **    so we compare the strings keccak256 hashes to see if the strings are equal
    **
    ** -> Solidity supports inheritance between smart contracts
    **
    ** -> There are two locations where you can stores variables :
    **    1- storage : refers to variables stored permanently on the blockchain
    **    2- memory : variables are temporary, and are erased between external function calls to your contract.
    **    By default, State variables (variables declared outside of functions) are by default storage and written
    **    permanently to the blockchain, while variables declared inside functions are memory and will disappear
    **    when the function call ends.
    **
    ** -> in Solidity you can return more than one value from a function.
    */
}

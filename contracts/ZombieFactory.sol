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

    /* functions are public by default, which means that anyone or any other contract can call and execute them
       which can make your contract vulnerable to attacks
       A good practice is to always make your functions private unless you need them to be public
    */
    function _createZombie(string memory _name, uint _dna) private {
        uint id = zombies.push(Zombie(_name, _dna)) - 1;
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
        uint randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }

}

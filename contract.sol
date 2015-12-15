contract smartDoor {
	
	struct operation {
		uint signaturesNeeded;
		uint signatures;
		uint index;
	}
	
	uint[255] registeredUsers;
	mapping (uint => uint) registeredUsersIndex;
	uint numOfRegisteredUsers;
	
	uint requiredVotes = 2;
	bytes32[] pendingTransactions;
	mapping(bytes32 => operation) pendingTransactionsMap;
	
	modifier onlyOwner (address _address) {
		if( isOwner(_address)){
			_
		}
	}
	
	modifier onlyManyOwners (bytes32 _operation){
		if (checkAndVerify(_operation)){
			_
		}
	}
	
	function smartDoor(address[] _registeredUsers){
		numOfRegisteredUsers = _registeredUsers.length;
		for (uint i = 0; i < _registeredUsers.length; i++){
			registeredUsers[i+1] = uint(_registeredUsers[i]);
			registeredUsersIndex[uint(_registeredUsers[i])] = i+1;
		}
	}
	
	function openDoor() onlyOwner(tx.origin) external returns (bool){
		return true;
	}
	
	function addOwner(address _address) onlyManyOwners(sha3("addOwner",_address)) external returns (bool) {
		numOfRegisteredUsers++;
		registeredUsers[numOfRegisteredUsers] = uint(_address);
		registeredUsersIndex[uint(_address)] = numOfRegisteredUsers;
		return true;
	}
	
	function isOwner (address _address) internal returns (bool){
		uint userIndex = registeredUsersIndex[uint(_address)];
		if (userIndex == 0) return false;
		return true;
	}
	
	function howManyOwners() constant returns (uint) {
		return numOfRegisteredUsers;
	}
	
	function getOwners() constant returns (uint[255]) {
		return registeredUsers;
	}
	
	function getOwnersIndex(address _address) constant returns (uint) {
		return registeredUsersIndex[uint(_address)];
	}
	
	function checkAndVerify(bytes32 _operation) internal returns (bool) {
		if (!isOwner(tx.origin)) return;
		uint userIndex = registeredUsersIndex[uint(tx.origin)];
		
		var trxn = pendingTransactionsMap[_operation];
		
		if (trxn.signaturesNeeded == 0){
			trxn.signaturesNeeded = requiredVotes;
			trxn.signatures = 0;
			trxn.index = pendingTransactions.length++;
			pendingTransactions[trxn.index] = _operation;
		}
		
		uint ownersIndexBit = 2**userIndex;
		if (trxn.signatures & ownersIndexBit == 0){
			if (trxn.signaturesNeeded <= 1){
				delete pendingTransactions[trxn.index];
				delete pendingTransactionsMap[_operation];
				return true;
				
			} else {
				trxn.signaturesNeeded--;
				trxn.signatures = trxn.signatures | ownersIndexBit;
			}
		}
		
	}
}
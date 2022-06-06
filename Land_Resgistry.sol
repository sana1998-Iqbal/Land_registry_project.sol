// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
contract LandRegistration{
    //Create LandRegistry
    struct Landregistry{
        uint LandId;
        uint Area;
        string City;
        string State;
        uint LandPrice;
        uint PropertyPID;
    }

    //Buyer Details
    struct Buyer
    {
        address Id;
        string Name;
        uint Age;
        string City;
        uint CNIC;
        string Email;
    }

    //Seller Details
    struct Seller
    {
        address Id;
        string Name;
        uint Age;
        string City;
        uint CNIC;
        string Email; 
    }
        
    //LandInspector Details(who deploy contract)
    struct LandInspector 
    {
        uint Id;
        string Name;
        uint Age;
        string Designation;
    }

    //details of LandRequest
    struct LandRequest{
        uint reqId;
        address sellerId;
        address buyerId;
        uint landId;
    }

    mapping(uint => LandInspector) public InspectorMapping;
    mapping(uint => Landregistry) public lands;
    mapping(address => Buyer) public BuyerMapping;
    mapping(address => Seller) public SellerMapping; //(use different account for buyer and seller)
    mapping(uint => LandRequest) public RequestsMapping;
    
    mapping(address => bool) public RegisteredSellerMapping;
    mapping(address => bool) public RegisteredAddressMapping;
    mapping(address => bool) public RegisteredBuyerMapping;
    mapping(address => bool) public SellerVerification;
    mapping(address => bool) public SellerRejection;
    mapping(address => bool) public BuyerVerification;
    mapping(address => bool) public BuyerRejection;
    mapping(uint => address) public LandsOwner;
    mapping(uint => bool) public LandVerification;
    mapping(uint => bool) public RequestStatus;
    mapping(uint => bool) public RequestedLands;
    mapping(uint => bool) public PaymentReceived;
    
    event Landrequested(address _sellerId);
    event Registration(address _registrationId);
    event Verified(address _id);
    event Rejected(address _id);
    
    address public owner_Land_Inspector;
    uint public InspectorsCount;
    uint public sellersCount;
    address[] private reg_seller;
    uint public LandCount;
    uint public requestsCount;
    uint public BuyerCount;
    address[] private reg_buyer;

    // owner is land_Inspector
    constructor(){
    owner_Land_Inspector=msg.sender;
    }
    function is_Land_Inspector(address _id) public view returns (bool) {
        if(owner_Land_Inspector == _id){
        return true;
        }else{
        return false;
        }
    }

    function addLandInspector(string memory _name, uint _age, string memory _designation) private {
        InspectorsCount++;
        InspectorMapping[InspectorsCount] = LandInspector(InspectorsCount, _name, _age, _designation);
    }

    //check ID of seller is registered or not
    function isSeller(address _id) public view returns (bool) {
        if(RegisteredSellerMapping[_id]){
        return true;
        }
    }

      //registration of seller
    function registerSeller(string memory _name, uint _age, string memory _city, uint _cnic,string memory _email) public {
        require(!RegisteredAddressMapping[msg.sender]); //seller not already register
        RegisteredAddressMapping[msg.sender] = true;
        RegisteredSellerMapping[msg.sender] = true ;
        sellersCount++;
        SellerMapping[msg.sender] = Seller(msg.sender, _name, _age, _city, _cnic, _email);
        reg_seller.push(msg.sender);
        emit Registration(msg.sender);
    }

    //get address_of_seller
    function getSellerAddress() public view returns( address [] memory){
    return (reg_seller);
    }
    
    //SellerVerify by owner
    function verifySeller(address _sellerId) public{
        require(is_Land_Inspector(msg.sender));
        SellerVerification[_sellerId] = true;
        emit Verified( _sellerId);
    }

    //SellerReject by owner
    function rejectSeller(address _sellerId) public{
        require(is_Land_Inspector(msg.sender));
        SellerRejection[_sellerId] = true;
    emit Rejected( _sellerId);

    }

    //SellerIsVerified
    function SellerIsVerified(address _id)public view returns(bool){
        require(SellerVerification[_id]);
        return true;
    }

    // buyer OR seller verify
    function isVerified(address _id) public view returns (bool) {
        if(SellerVerification[_id] || BuyerVerification[_id]){
            return true;
        }
    }
 
     //check verification of seller & add land details
    function AddLandDetails(uint _LandId,uint _Area,string memory _city, string memory _state, uint _landPrice, uint _PropertyPID) public {
        require((isSeller(msg.sender)) && (isVerified(msg.sender)));
        //require((isSeller(msg.sender)) && (SellerIsVerified(msg.sender)) ); //is seller verified
        LandCount++;
        lands[LandCount] = Landregistry( _LandId, _Area, _city, _state, _landPrice, _PropertyPID);
        LandsOwner[LandCount]=msg.sender;
    }

    // get land details separately
    function GetLandArea(uint i) public view returns (uint) {
    return lands[i].Area;
    }
    function GetLandPrice(uint i) public view returns (uint) {
    return lands[i].LandPrice;
    }
    function GetLandCity(uint i) public view returns (string memory) {
    return lands[i].City;
    }
    function GetPropertyPID(uint i) public view returns (uint) {
    return lands[i].PropertyPID;
    }
    function GetLandState(uint i) public view returns (string memory) {
    return lands[i].State;
    }
    
    //land added by seller verify by Owner
    function verifyLand(uint _LandId) public{
        require(is_Land_Inspector(msg.sender));
        LandVerification[_LandId] = true;
    }

    //land verified or not
    function LandIsVerified(uint _x)public view returns(bool){
        require(LandVerification[_x]);
        return true;
     }
    
    //Get Land Details By LandID
    function getLandDetails(uint i)public view returns(uint,string memory,string memory,uint,uint) {
    return ( lands[i].Area, lands[i].City, lands[i].State, lands[i].LandPrice, lands[i].PropertyPID);
    }    

    //update seller details
    function updateSeller(string memory _name, uint _age, string memory _city, uint _cnic,string memory _email) public {
        require(RegisteredAddressMapping[msg.sender] && (SellerMapping[msg.sender].Id == msg.sender));

        SellerMapping[msg.sender].Name = _name;
        SellerMapping[msg.sender].Age = _age;
        SellerMapping[msg.sender].City = _city;
        SellerMapping[msg.sender].CNIC = _cnic;
        SellerMapping[msg.sender].Email = _email;
    }

    //get details of seller
    function getSellerDetails(address i) public view returns ( string memory, uint, string memory, uint, string memory) {
        return (SellerMapping[i].Name, SellerMapping[i].Age, SellerMapping[i].City, SellerMapping[i].CNIC, SellerMapping[i].Email);
    }

     //registration of buyer 
    function registerBuyer(string memory _name, uint _age, string memory _city, uint _cnic,string memory _email) public {
        require(!RegisteredAddressMapping[msg.sender]); //buyer not already register
        RegisteredAddressMapping[msg.sender] = true;
        RegisteredSellerMapping[msg.sender] = true ;
        BuyerCount++;
        BuyerMapping[msg.sender] = Buyer(msg.sender, _name, _age, _city, _cnic, _email);
        reg_buyer.push(msg.sender);
        emit Registration(msg.sender);
    }
  
    //get address_of_buyer
    function getBuyerAddress() public view returns( address [] memory){
    return (reg_buyer);
    }
    
    //BuyerVerify by owner
    function verifyBuyer(address _buyerId) public{
        require(is_Land_Inspector(msg.sender));
        BuyerVerification[_buyerId] = true;
        emit Verified(_buyerId);
    }

    //BuyerReject by owner
    function rejectBuyer(address _buyerId) public{
        require(is_Land_Inspector(msg.sender));
        BuyerRejection[_buyerId] = true;
        emit Rejected(_buyerId);
    }

    //BuyerIsVerified
    function BuyerIsVerified(address _id)public view returns(bool){
        require(BuyerVerification[_id]);
        return true;
    }

    //update buyer details
    function updateBuyer(string memory _name, uint _age, string memory _city, uint _cnic,string memory _email) public {
        require(RegisteredAddressMapping[msg.sender] && (BuyerMapping[msg.sender].Id == msg.sender));

        BuyerMapping[msg.sender].Name = _name;
        BuyerMapping[msg.sender].Age = _age;
        BuyerMapping[msg.sender].City = _city;
        BuyerMapping[msg.sender].CNIC = _cnic;
        BuyerMapping[msg.sender].Email = _email;
    }

    //get details of buyer
    function getBuyerDetails(address i) public view returns ( string memory, uint, string memory, uint, string memory) {
        return (BuyerMapping[i].Name, BuyerMapping[i].Age, BuyerMapping[i].City, BuyerMapping[i].CNIC, BuyerMapping[i].Email);
    }
    
    //buyer is register or not
    function isBuyer(address _id) public view returns (bool) {
        if(RegisteredBuyerMapping[_id]){
            return true;
        }
    }

    //buyer can buy land only if buyer and land both verified
    function requestLand(address _sellerId, uint _landId) public{
        require(isBuyer(msg.sender) && isVerified(msg.sender));
        requestsCount++;
        RequestsMapping[requestsCount] = LandRequest(requestsCount, _sellerId, msg.sender, _landId);
        RequestStatus[requestsCount] = false;
        RequestedLands[requestsCount] = true;
        emit Landrequested(_sellerId);
    }
    
    //get details about land request (who is buyer ,who is seller ,landId , request Status)
    function getRequestDetails (uint i) public view returns (address, address, uint, bool) {
        return(RequestsMapping[i].sellerId, RequestsMapping[i].buyerId, RequestsMapping[i].landId, RequestStatus[i]);
    }

    //check requestId
    function isRequested(uint _id) public view returns (bool) {
        if(RequestedLands[_id]){
            return true;
        }
    }

    //check is approve?
    function isApproved(uint _id) public view returns (bool) {
        if(RequestStatus[_id]){
            return true;
        }
    }

    // reqId is approved
    function approveRequest(uint _reqId) public {
        require((isSeller(msg.sender)) && (isVerified(msg.sender)));
        RequestStatus[_reqId] = true;

    }

    //currentLandsowner address
    function getLandsOwner(uint _id)public view returns(address){
    return LandsOwner[_id];
    }

    //buyer give amount and landId they wany to buy
    function payment(address payable _receiver, uint _landId) public payable {
        PaymentReceived[_landId] = true;
        _receiver.transfer(msg.value);
    }

    function isPaid(uint _landId) public view returns (bool) {
        if(PaymentReceived[_landId]){
            return true;
        }
    }

    //OwnerShip Change From current to newOwner
    function LandOwnershipTransfer(uint _landId, address _newOwner) public{
        require(is_Land_Inspector(msg.sender));
        LandsOwner[_landId] = _newOwner;
    }

}
    

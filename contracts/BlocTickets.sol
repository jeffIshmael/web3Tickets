// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract BlocTickets is ERC721URIStorage, Ownable {


    IERC20 public cUSDToken;
    address public mine;
       
    // address public cUSDTokenAddress = // 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1 //testnet
    // 0x765DE816845861e75A25fCA122bb6898B8B1282a //mainnet

    constructor() ERC721("BlocTickets", "BTK") {
        mine = msg.sender;
        cUSDToken = IERC20(0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1);
    }


    struct Event {
        uint id;
        address organizer;
        string name;
        string venue;
        string category;
        uint date;
        string time;
        uint price;
        uint ticketsAvailable;
        string description;
        string ipfs;
        address[] ticketHolders;
        string[] nftUris;
        mapping(address => string[]) userToNftUris; // Map user address to NFT URIs for this event
        mapping(address => uint8) ratings; // Stores ratings by each attendee (1-5)
        Comment[] comments; // Array to store all comments for this event
        uint totalRating;
        uint ratingCount;
    }

    struct Comment {
        address commenter;
        string text;
        uint timestamp;
    }


    struct EventView {
        uint id;
        address organizer;
        string name;
        string venue;
        string category;
        uint date;
        string time;
        uint price;
        uint ticketsAvailable;
        string description;
        string ipfs;
        address[] ticketHolders;
        string[] nftUris;
        uint averageRating;
    }

    Event[] public events;
    uint public nextEventId;
    uint public nextTicketId;


    function createEvent(
        string memory name,
        string memory venue,
        string memory category,
        uint date,
        string memory time,
        uint price,
        string memory ipfs,
        uint ticketsAvailable,
        string memory description
    ) public {
        require(date > block.timestamp, "Event date should be in the future");
        require(ticketsAvailable > 0, "Tickets available should be greater than zero");

        Event storage newEvent = events.push();
        newEvent.id = nextEventId;
        newEvent.organizer = msg.sender;
        newEvent.name = name;
        newEvent.venue = venue;
        newEvent.category = category;
        newEvent.date = date;
        newEvent.time = time;
        newEvent.price = price;
        newEvent.ipfs = ipfs;
        newEvent.ticketsAvailable = ticketsAvailable;
        newEvent.description = description;

        nextEventId++;
    }

    function buyTicket(uint eventId, string memory nftUri) public payable {
        Event storage _event = events[eventId];       
        require(_event.ticketsAvailable > 0, "No tickets available");        
        mintTicketNft(eventId, nftUri);
        _event.ticketsAvailable--;
        _event.ticketHolders.push(msg.sender);
  
    }

    function mintTicketNft(uint eventId, string memory nftUri) internal {
        Event storage _event = events[eventId];
        _event.nftUris.push(nftUri);
        _event.userToNftUris[msg.sender].push(nftUri);

        uint ticketId = nextTicketId;
        _mint(msg.sender, ticketId);
        _setTokenURI(ticketId, nftUri);

        nextTicketId++;
    }

    function submitRating(uint eventId, uint8 rating) public {
        Event storage _event = events[eventId];
        require(block.timestamp > _event.date, "Rating can only be given after the event date");
        require(rating >= 1 && rating <= 5, "Rating should be between 1 and 5");
        require(_event.ratings[msg.sender] == 0, "You have already rated this event");

        _event.ratings[msg.sender] = rating;
        _event.totalRating += rating;
        _event.ratingCount += 1;
    }

    function getAverageRating(uint eventId) public view returns (uint) {
        Event storage _event = events[eventId];
        if (_event.ratingCount == 0) return 0;
        return _event.totalRating / _event.ratingCount;
    }

    function submitComment(uint eventId, string memory comment) public {
        Event storage _event = events[eventId];
        bool isTicketHolder = false;
        
        // Check if the sender is a ticket holder
        for (uint i = 0; i < _event.ticketHolders.length; i++) {
            if (_event.ticketHolders[i] == msg.sender) {
                isTicketHolder = true;
                break;
            }
        }

        require(isTicketHolder, "Only ticket holders can comment on the event");

        _event.comments.push(Comment(msg.sender, comment, block.timestamp));
    }

    function getAllComments(uint eventId) public view returns (Comment[] memory) {
        Event storage _event = events[eventId];
        return _event.comments;
    }

    function getEvent(uint eventId) public view returns (
        uint,
        address,
        string memory,
        string memory,
        string memory,
        uint,
        string memory,
        uint,
        uint,
        string memory,
        string memory,
        address[] memory,
        string[] memory,
        Comment[] memory,
        uint,
        uint
    ) {
        Event storage _event = events[eventId];
        return (
            _event.id,
            _event.organizer,
            _event.name,
            _event.venue,
            _event.category,
            _event.date,
            _event.time,
            _event.price,
            _event.ticketsAvailable,
            _event.description,
            _event.ipfs,
            _event.ticketHolders,
            _event.nftUris,
            _event.comments,            
            _event.totalRating,
            _event.ratingCount
        );
    }

    function getAllEvents() public view returns (EventView[] memory) {
        EventView[] memory result = new EventView[](events.length);
        for (uint i = 0; i < events.length; i++) {
            Event storage _event = events[i];
            result[i] = EventView(
                _event.id,
                _event.organizer,
                _event.name,
                _event.venue,
                _event.category,
                _event.date,
                _event.time,
                _event.price,
                _event.ticketsAvailable,
                _event.description,
                _event.ipfs,
                _event.ticketHolders,
                _event.nftUris,
                _event.totalRating
            
            );
        }
        return result;
    }

    function getUserPurchasedTickets(uint eventId, address user) public view returns (string[] memory) {
        Event storage _event = events[eventId];
        return _event.userToNftUris[user];
    }

    function getUserPurchasedEvents(address user) public view returns (EventView[] memory) {
        uint count = 0;
        for (uint i = 0; i < events.length; i++) {
            for (uint j = 0; j < events[i].ticketHolders.length; j++) {
                if (events[i].ticketHolders[j] == user) {
                    count++;
                    break;
                }
            }
        }

        EventView[] memory result = new EventView[](count);
        uint index = 0;
        for (uint i = 0; i < events.length; i++) {
            for (uint j = 0; j < events[i].ticketHolders.length; j++) {
                if (events[i].ticketHolders[j] == user) {
                    Event storage _event = events[i];
                    result[index] = EventView(
                        _event.id,
                        _event.organizer,
                        _event.name,
                        _event.venue,
                        _event.category,
                        _event.date,
                        _event.time,
                        _event.price,
                        _event.ticketsAvailable,
                        _event.description,
                        _event.ipfs,
                        _event.ticketHolders,
                        _event.nftUris,
                        _event.totalRating
                    );
                    index++;
                    break;
                }
            }
        }

        return result;
    }

    function getEventsByOrganizer(address organizer) public view returns (EventView[] memory) {
        uint count = 0;
        for (uint i = 0; i < events.length; i++) {
            if (events[i].organizer == organizer) {
                count++;
            }
        }

        EventView[] memory result = new EventView[](count);
        uint index = 0;
        for (uint i = 0; i < events.length; i++) {
            if (events[i].organizer == organizer) {
                Event storage _event = events[i];
                result[index] = EventView(
                    _event.id,
                    _event.organizer,
                    _event.name,
                    _event.venue,
                    _event.category,
                    _event.date,
                    _event.time,
                    _event.price,
                    _event.ticketsAvailable,
                    _event.description,
                    _event.ipfs,
                    _event.ticketHolders,
                    _event.nftUris,
                    _event.totalRating
                );
                index++;
            }
        }
        return result;
    }

    function getUserTickets(address user) public view returns (string[] memory) {
        uint totalTickets = 0;

        // First, calculate the total number of tickets owned by the user
        for (uint i = 0; i < events.length; i++) {
            totalTickets += events[i].userToNftUris[user].length;
        }

        // Create an array to hold all ticket URIs
        string[] memory ticketUris = new string[](totalTickets);
        uint index = 0;

        // Populate the ticket URIs array
        for (uint i = 0; i < events.length; i++) {
            string[] storage userTickets = events[i].userToNftUris[user];
            for (uint j = 0; j < userTickets.length; j++) {
                ticketUris[index] = userTickets[j];
                index++;
            }
        }

        return ticketUris;
    }


    //function to withdraw from the contract
    function withdraw(address _address) public onlyContractOwner {
        require(cUSDToken.transfer(_address, cUSDToken.balanceOf(address(this))), "Unable to withdraw from contract");
    }

    //modifier for onlyOwner
    modifier onlyContractOwner() {
        require(msg.sender == mine , "Only owner can call this function");
        _;
    }
}

// Assume APTOS token v2 standard is defined

// Define ObjectCore for ownership
resource struct ObjectCore {
    owner: address
}

// Define Aptos object for tickets
resource struct Aptos {
    event_id: u64,
    ticket_id: u64,
    owner: address,
    price: u64
}

// Define Event object
resource struct Event {
    organizer: address,
    initial_price: u64,
    total_tickets: u64,
    tickets_sold: u64,
    event_date: u64,
    ticket_supply: vector<Aptos>
}


public let COMMISSION_RATE: u64 = 1; // 1% commission rate


public fun create_event(initial_price: u64, total_tickets: u64, event_date: u64): Event {
    let organizer: address = get_sender();
    let event: Event = Event {
        organizer: organizer,
        initial_price: initial_price,
        total_tickets: total_tickets,
        tickets_sold: 0,
        event_date: event_date,
        ticket_supply: empty<vector<Aptos>>()
    };
    return event;
}

// Function to buy a ticket
public fun buy_ticket(event: &mut Event, buying_price: u64, buyer: address) {
    assert(move(event.event_date > current_timestamp()), 1); // Ensure the event date hasn't passed
    assert(move(event.tickets_sold < event.total_tickets), 2); // Ensure there are available tickets

    
    let ticket_to_buy: &Aptos;
    if (buying_price > 0) {
        ticket_to_buy = find_ticket_by_price(&event.ticket_supply, buying_price);
    } else {
        ticket_to_buy = find_cheapest_ticket(&event.ticket_supply);
    }

    
    let commission: u64 = calculate_commission(ticket_to_buy.price, COMMISSION_RATE);

   
    transfer_tokens(buyer, event.organizer, ticket_to_buy.price - commission);
    transfer_tokens(buyer, 0x1, commission / 2); // Buyer's commission
    transfer_tokens(event.organizer, 0x1, commission / 2); // Seller's commission

    
    ticket_to_buy.owner = move(buyer);

    
    event.tickets_sold = move(event.tickets_sold + 1);
}

// Function to sell a ticket
public fun sell_ticket(event: &mut Event, selling_price: u64) {
    assert(move(event.event_date > current_timestamp()), 1); // Ensure the event date hasn't passed
    assert(move(event.tickets_sold < event.total_tickets), 2); // Ensure there are available tickets

    
    let ticket: Aptos = Aptos {
        event_id: 0, // You might want to set this to a specific event ID
        ticket_id: event.tickets_sold + 1,
        owner: event.organizer,
        price: selling_price
    };
    event.ticket_supply.push(move(ticket));

    
    event.tickets_sold = move(event.tickets_sold + 1);
}

// Function to find the cheapest available ticket
public fun find_cheapest_ticket(tickets: &vector<Aptos>): &Aptos {
    let cheapest_ticket: &Aptos;
    let min_price: u64 = u64::max_value();

    for ticket in tickets {
        if ticket.price < min_price {
            min_price = move(ticket.price);
            cheapest_ticket = move(ticket);
        }
    }

    return cheapest_ticket;
}

// Function to find a ticket by a specific price
public fun find_ticket_by_price(tickets: &vector<Aptos>, target_price: u64): &Aptos {
    for ticket in tickets {
        if ticket.price == target_price {
            return ticket;
        }
    }
    assert(false, 1); // Ticket with the specified price not found
}

// Function to calculate commission
public fun calculate_commission(amount: u64, rate: u64): u64 {
    return (amount * rate) / 100;
}

// Function to transfer tokens
public fun transfer_tokens(sender: address, receiver: address, amount: u64) {
   
}

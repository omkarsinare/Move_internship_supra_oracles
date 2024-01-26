// Assume APTOS token v2 standard is defined

// Define ObjectCore for ownership
resource struct ObjectCore {
    owner: address
}

// Define Loan resource
resource struct Loan {
    borrower: address,
    amount: u64,
    interest_rate: u64,
    duration: u64,
    remaining_amount: u64,
    installment_amount: u64,
    penalty_rate: u64,
    prepayment_fee_rate: u64,
    last_payment_timestamp: u64,
    status: u8 // 0: Active, 1: Paid, 2: Defaulted
}

// Global variables
public let INIT_CORPUS: u64 = 1000000; // Initial money supply for the bank
public let MIN_DURATION: u64 = 1; // Minimum loan duration in seconds
public let MAX_DURATION: u64 = 31536000; // Maximum loan duration in seconds (1 year)
public let MIN_INTEREST_RATE: u64 = 1; // Minimum interest rate (1%)
public let MAX_INTEREST_RATE: u64 = 10; // Maximum interest rate (10%)
public let PENALTY_RATE: u64 = 5; // Penalty rate for late payments (5%)
public let PREPAYMENT_FEE_RATE: u64 = 2; // Prepayment fee rate (2%)

// Function to initialize the bank
public fun initialize_bank(): ObjectCore {
    let bank: ObjectCore = ObjectCore {
        owner: 0x1 // Bank's address (replace with the actual address)
    };
    
    return bank;
}

// Function for a customer to apply for a loan
public fun apply_for_loan(amount: u64, duration: u64): Loan {
    let borrower: address = get_sender();
    assert(move(amount > 0), 1); // Loan amount should be greater than 0
    assert(move(duration >= MIN_DURATION && duration <= MAX_DURATION), 2); 
    
    let interest_rate: u64 = MAX_INTEREST_RATE - ((duration - MIN_DURATION) * (MAX_INTEREST_RATE - MIN_INTEREST_RATE) / (MAX_DURATION - MIN_DURATION));

    let loan: Loan = Loan {
        borrower: borrower,
        amount: amount,
        interest_rate: interest_rate,
        duration: duration,
        remaining_amount: amount,
        installment_amount: calculate_installment(amount, interest_rate, duration),
        penalty_rate: PENALTY_RATE,
        prepayment_fee_rate: PREPAYMENT_FEE_RATE,
        last_payment_timestamp: 0,
        status: 0 // Active
    };
    
    return loan;
}

// Function to calculate the installment amount
public fun calculate_installment(amount: u64, interest_rate: u64, duration: u64): u64 {
    let total_interest: u64 = (amount * interest_rate * duration) / 100;
    let total_payment: u64 = amount + total_interest;
    return total_payment / duration;
}

// Function to make a loan installment payment
public fun make_payment(loan: &mut Loan, payment_amount: u64) {
    let current_timestamp: u64 = current_timestamp();
    assert(move(current_timestamp >= loan.last_payment_timestamp), 1); // Ensure payment is not made before the last payment timestamp
    assert(move(payment_amount >= loan.installment_amount), 2); // Ensure payment amount is sufficient

    let outstanding_amount: u64 = loan.remaining_amount + (loan.remaining_amount * loan.interest_rate * (current_timestamp - loan.last_payment_timestamp) / (100 * loan.duration));

    if (payment_amount > outstanding_amount) {
        
        let prepayment_fee: u64 = (payment_amount - outstanding_amount) * loan.prepayment_fee_rate / 100;
        
    }

    let remaining_principal: u64 = outstanding_amount - payment_amount;

    if (remaining_principal == 0) {
        loan.status = 1; // Loan fully paid
    } else if (current_timestamp > (loan.last_payment_timestamp + loan.duration)) {
        // Late payment, apply penalty
        let penalty: u64 = remaining_principal * loan.penalty_rate / 100;
        // Transfer the penalty to the bank
        // Implement token transfer logic (not provided in this example)
    }

    // Update loan details
    loan.remaining_amount = move(remaining_principal);
    loan.last_payment_timestamp = move(current_timestamp);
}

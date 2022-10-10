report 50106 "WDC Customer Debit Progress"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/Report/RDLC/WDCCustomerDebitProgress.rdl';
    AdditionalSearchTerms = 'Customer Debit Progress';
    ApplicationArea = Basic, Suite;
    Caption = 'Customer Debit Progress';
    EnableHyperlinks = true;
    UsageCategory = ReportsAndAnalysis;
    Description = 'Customer Debit Progress';
    dataset
    {
        dataitem(Customer; Customer)
        {
            RequestFilterFields = "No.", "Salesperson Code", "1st Group", "2nd Group", "3rd Group", "4th Group";
            DataItemTableView = where("No." = filter('C*'));
            column(GLFilter; GLFilter)
            {
            }
            column(CompanyInfoName; CompanyInfo.Name)
            {
            }
            column(FromDate; FromDate)
            {
            }
            column(ToDate; ToDate)
            {
            }

            column(CustNo; Customer."No.")
            {
            }

            column(CustName; Customer.Name)
            {
            }
            column(Group1; "1st Group")
            {

            }
            column(Group2; "2nd Group")
            {

            }
            column(Group3; "3rd Group")
            {

            }

            column(SalespersonInv; Customer."Salesperson Code")
            {

            }
            column(PaymentTermeCustomer; customer."Payment Terms Code")
            {
            }
            column(Credit_Limit_LCY_Blocked_; "Credit Limit LCY(Blocked)")
            {
            }
            column(Credit_Limit__LCY_; "Credit Limit (LCY)")
            {
            }

            column(PrviousBalance; GetPrviousBalance(customer."No.", FromDate - 1))
            {
            }

            column(InvoiceAndCrdMemo; GetInvoiceAndCrdMemo(customer."No.", FromDate, ToDate))
            {

            }
            column(ShippedNotInvoiced; GetShippedNotInvoiced(customer."No.", FromDate, ToDate))
            {

            }
            column(ReturnedNotInvoiced; GetReturnedNotInvoiced(customer."No.", FromDate, ToDate))
            {

            }
            column(Payment; GetPayment(customer."No.", FromDate, ToDate))
            {

            }
            column(Impaid; GetImpaid(customer."No.", FromDate, ToDate))
            {

            }

            column(TotalChqAndTrtByManager; GetTotalChqAndTrtByManager(customer."No.", FromDate, ToDate))
            {

            }

            column(CashByManager; GetCashByManager(customer."No.", FromDate, ToDate))
            {

            }
            column(ChqAndTrtWaitToEncaise; GetChqAndTrtWaitToEncaise(customer."No.", FromDate, ToDate))
            {

            }

            column(LineNo; LineNo)
            {

            }


            trigger OnPreDataItem()
            begin
                CompanyInfo.get;
                GLFilter := Customer.GetFilters;
                LineNo := 0;
            end;

            trigger OnAfterGetRecord()
            begin
                LineNo += 1;
            end;



        }

    }
    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Filters)
                {
                    Caption = 'Filter';
                    field(StartDateFilter; FromDate)
                    {
                        ApplicationArea = all;
                        Caption = 'Start Date';
                    }
                    field(EndtDateFilter; ToDate)
                    {
                        ApplicationArea = all;
                        Caption = 'End Date';
                    }

                }
            }
        }
    }

    trigger OnPreReport()
    var
        ltext001: Label 'You should put the both filter date ';
        ltext002: Label 'Starting Date filter should be inferior then the Ending Date';
    begin

        If (FromDate = 0D) Or (ToDate = 0D) then
            Error(ltext001);
        IF (FromDate > ToDate) and (ToDate <> 0D) then
            Error(ltext002);

    end;

    procedure GetPrviousBalance(pCustNo: code[20]; pDateLimit: Date): Decimal
    var
        lDetCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        lTotal: Decimal;
    begin
        lDetCustLedgEntry.Reset();
        lDetCustLedgEntry.SetCurrentKey("Customer No.", "Entry Type", "Posting Date", "Initial Document Type");
        lDetCustLedgEntry.SetFilter("Posting Date", '..%1', pDateLimit);
        lDetCustLedgEntry.SetRange("Customer No.", pCustNo);
        If lDetCustLedgEntry.FindSet() Then
            lDetCustLedgEntry.CalcSums("Amount (LCY)");
        lTotal := lDetCustLedgEntry."Amount (LCY)";
        exit(lTotal);
    end;

    procedure GetInvoiceAndCrdMemo(pCustNo: code[20]; pStartDate: Date; pEndDate: Date): Decimal
    var
        lDetCustLedgEntry: record "Detailed Cust. Ledg. Entry";
        lTotal: Decimal;
    begin
        lDetCustLedgEntry.Reset();
        lDetCustLedgEntry.SetCurrentKey("Customer No.", "Entry Type", "Posting Date", "Initial Document Type");
        lDetCustLedgEntry.SetRange("Customer No.", pCustNo);
        lDetCustLedgEntry.Setrange("Entry Type", lDetCustLedgEntry."Entry Type"::"Initial Entry");
        lDetCustLedgEntry.SetFilter("Document Type", '%1|%2', lDetCustLedgEntry."Document Type"::"Credit Memo", lDetCustLedgEntry."Document Type"::Invoice);
        lDetCustLedgEntry.SetRange("Posting Date", pStartDate, pEndDate);
        if lDetCustLedgEntry.Findset() Then
            lDetCustLedgEntry.CalcSums("Amount (LCY)");
        lTotal := lDetCustLedgEntry."Amount (LCY)";
        exit(lTotal);
    end;

    procedure GetShippedNotInvoiced(pCustNo: code[20]; pStartDate: Date; pEndDate: Date): Decimal
    var
        lSalesLines: record "Sales Line";
        lTotal: Decimal;
    begin
        lSalesLines.Reset();
        lSalesLines.SetCurrentKey("Document Type", "Bill-to Customer No.", "Currency Code", "Document No.");
        lSalesLines.SetRange("Sell-to Customer No.", pCustNo);
        lSalesLines.SetRange("Document Type", lSalesLines."Document Type"::Order);
        lSalesLines.SetRange("Posting Date", pStartDate, pEndDate);
        lSalesLines.SetFilter(type, '<>%1', lSalesLines.Type::"G/L Account");
        lSalesLines.SetFilter("Shipped Not Invoiced (LCY)", '<>%1', 0);
        if lSalesLines.FindSet() then
            lSalesLines.CalcSums("Shipped Not Invoiced (LCY)");
        lTotal := lSalesLines."Shipped Not Invoiced (LCY)";
        exit(lTotal);
    end;

    procedure GetReturnedNotInvoiced(pCustNo: code[20]; pStartDate: Date; pEndDate: Date): Decimal
    var
        lSalesLines: record "Sales Line";
        lTotal: Decimal;
    begin
        lSalesLines.Reset();
        lSalesLines.SetCurrentKey("Document Type", "Bill-to Customer No.", "Currency Code", "Document No.");
        lSalesLines.SetRange("Sell-to Customer No.", pCustNo);
        lSalesLines.SetRange("Document Type", lSalesLines."Document Type"::"Return Order");
        lSalesLines.SetRange("Posting Date", pStartDate, pEndDate);
        lSalesLines.SetFilter(type, '<>%1', lSalesLines.Type::"G/L Account");
        lSalesLines.SetFilter("Return Rcd. Not Invd. (LCY)", '<>%1', 0);
        if lSalesLines.FindSet() then
            lSalesLines.CalcSums("Return Rcd. Not Invd. (LCY)");
        lTotal := lSalesLines."Return Rcd. Not Invd. (LCY)";
        exit(lTotal);
    end;

    procedure GetPayment(pCustNo: code[20]; pStartDate: Date; pEndDate: Date): Decimal
    var
        lCustLedgEnt: Record 21;
        lGlEntries: record 17;
        lTotalPayment: Decimal;
    begin
        lCustLedgEnt.Reset;
        lCustLedgEnt.SetCurrentKey("Document Type", "Customer No.", "Posting Date", "Currency Code");
        lCustLedgEnt.SetRange("Customer No.", pCustNo);
        lCustLedgEnt.SetRange("Posting Date", pStartDate, pEndDate);
        lCustLedgEnt.SetFilter("Document Type", '%1|%2', lCustLedgEnt."Document Type"::Payment, lCustLedgEnt."Document Type"::" ");
        lCustLedgEnt.SetRange("Cheque No.", '');
        lCustLedgEnt.SetRange("Code Status", '');
        if lCustLedgEnt.FindFirst() Then
            repeat
                lCustLedgEnt.CalcFields("Amount (LCY)");
                lTotalPayment += lCustLedgEnt."Amount (LCY)";
            until lCustLedgEnt.Next() = 0;

        lGlEntries.Reset;
        lGlEntries.SetCurrentKey("G/L Account No.", "Posting Date");
        lGlEntries.SetRange("Bal. Account Type", lGlEntries."Bal. Account Type"::"Bank Account");
        lGlEntries.SetRange("Customer No.", pCustNo);
        lGlEntries.SetRange("Posting Date", pStartDate, pEndDate);
        lGlEntries.SetFilter("Code Status", '%1|%2', 'TRT-004*', 'CH-004*');
        if lGlEntries.FindFirst() Then
            lGlEntries.CalcSums(Amount);
        lTotalPayment += lGlEntries.Amount;
        exit(lTotalPayment * (-1));
    end;

    procedure GetImpaid(pCustNo: code[20]; pStartDate: Date; pEndDate: Date): Decimal
    var
        lCustLedgEnt: Record 21;
        lTotImpaid: Decimal;
    begin
        lCustLedgEnt.Reset;
        lCustLedgEnt.SetCurrentKey("Document Type", "Customer No.", "Posting Date", "Currency Code");
        lCustLedgEnt.SetRange("Customer No.", pCustNo);
        lCustLedgEnt.SetRange("Posting Date", pStartDate, pEndDate);
        lCustLedgEnt.SetFilter("Cheque No.", '<>%1', '');
        lCustLedgEnt.SetFilter("Code Status", '%1|%2|%3|%4', 'TRT-006*', 'CH-006*', 'TRT-007*', 'CH-007*');
        if lCustLedgEnt.FindFirst() Then
            repeat
                lCustLedgEnt.CalcFields("Remaining Amt. (LCY)");
                lTotImpaid += lCustLedgEnt."Remaining Amt. (LCY)";
            until lCustLedgEnt.Next() = 0;
        exit(lTotImpaid);
    end;

    procedure GetTotalChqAndTrtByManager(pCustNo: code[20]; pStartDate: Date; pEndDate: Date): Decimal
    var
        lCustLedgEnt: Record 21;
        lTotal: Decimal;
    begin
        lCustLedgEnt.Reset;
        lCustLedgEnt.SetCurrentKey("Document Type", "Customer No.", "Posting Date", "Currency Code");
        lCustLedgEnt.SetRange("Customer No.", pCustNo);
        lCustLedgEnt.SetRange("Posting Date", pStartDate, pEndDate);
        lCustLedgEnt.SetFilter("Cheque No.", '<>%1', '');
        lCustLedgEnt.SetRange(Reversed, false);
        lCustLedgEnt.SetFilter("Code Status", '%1|%2', 'TRT-001*', 'CH-001*');
        if lCustLedgEnt.FindFirst() Then
            repeat
                lCustLedgEnt.CalcFields("Amount (LCY)");
                lTotal += lCustLedgEnt."Amount (LCY)";
            until lCustLedgEnt.Next() = 0;
        exit(lTotal * -1);
    end;


    procedure GetCashByManager(pCustNo: code[20]; pStartDate: Date; pEndDate: Date): Decimal
    var
        lCustLedgEnt: Record 21;
        lTotal: Decimal;
    begin
        lCustLedgEnt.Reset;
        lCustLedgEnt.SetCurrentKey("Document Type", "Customer No.", "Posting Date", "Currency Code");
        lCustLedgEnt.SetRange("Customer No.", pCustNo);
        lCustLedgEnt.SetRange("Posting Date", pStartDate, pEndDate);
        lCustLedgEnt.SetFilter("Code Status", '%1', 'CASH-SP');
        if lCustLedgEnt.FindFirst() Then
            repeat
                lCustLedgEnt.CalcFields("Amount (LCY)");
                lTotal += lCustLedgEnt."Amount (LCY)";
            until lCustLedgEnt.Next() = 0;
        exit(lTotal * -1);
    end;



    procedure GetChqAndTrtWaitToEncaise(pCustNo: code[20]; pStartDate: Date; pEndDate: Date): Decimal
    var
        lCustLedgEnt: Record 21;
        lTotal: Decimal;
    begin
        lCustLedgEnt.Reset;
        lCustLedgEnt.SetCurrentKey("Document Type", "Customer No.", "Posting Date", "Currency Code");
        lCustLedgEnt.SetRange("Customer No.", pCustNo);
        lCustLedgEnt.SetRange("Posting Date", pStartDate, pEndDate);
        lCustLedgEnt.SetFilter("Cheque No.", '<>%1', '');
        lCustLedgEnt.SetFilter("Code Status", '%1|%2|%3|%4|%5|%6', 'TRT-002*', 'CH-002*', 'TRT-003*', 'CH-003*', 'TRT-005*', 'CH-005*');
        if lCustLedgEnt.FindFirst() Then
            repeat
                lCustLedgEnt.CalcFields("Amount (LCY)");
                lTotal += lCustLedgEnt."Amount (LCY)";
            until lCustLedgEnt.Next() = 0;
        exit(lTotal * -1);
    end;

    var
        GLFilter: Text;
        CompanyInfo: Record "Company Information";
        InvoiceHeader: Record "Sales Invoice Header";
        LineNo: Integer;
        FromDate: Date;
        ToDate: Date;

}


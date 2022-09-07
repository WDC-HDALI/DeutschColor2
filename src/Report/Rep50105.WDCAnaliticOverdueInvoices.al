report 50105 "WDC Analitic Overdue Invoices"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/Report/RDLC/WDCAnOverdueInvoices.rdl';
    AdditionalSearchTerms = 'Analitic Overdue Invoices';
    ApplicationArea = Basic, Suite;
    Caption = 'Analitic Overdue Invoices';
    EnableHyperlinks = true;
    UsageCategory = ReportsAndAnalysis;
    Description = 'Analitic Overdue Invoices';
    dataset
    {
        dataitem("Cust. Ledger Entry"; "Cust. Ledger Entry")
        {

            DataItemTableView = SORTING("Customer No.", "Posting Date", "Currency Code") order(ascending)
                                           where("Document Type" = filter(2 | 3));

            column(CustNo; "Cust. Ledger Entry"."Customer No.")
            {
            }

            column(CustName; "Cust. Ledger Entry"."Customer Name")
            {
            }

            column(SalespersonInv; "Cust. Ledger Entry"."Sales person No.")
            {

            }
            column(PaymentTermeCustomer; customer."Payment Terms Code")
            {
            }
            column(PaymentTermeCode; InvoiceHeader."Payment Terms Code")
            {
            }

            column(PostingDate; "Cust. Ledger Entry"."Posting Date")
            {
            }

            column(DocumentNo; "Cust. Ledger Entry"."Document No.")
            {

            }
            column(AmntIncVatInv; "Cust. Ledger Entry"."Original Amt. (LCY)")
            {

            }
            column(RemainingAmtInv; "Cust. Ledger Entry"."Remaining Amt. (LCY)")
            {

            }
            column(DueDateInv; "Cust. Ledger Entry"."Due Date")
            {

            }
            // dataitem(DetCustLedgEntry; "Detailed Cust. Ledg. Entry")
            // {
            //     DataItemLink = "Applied Cust. Ledger Entry No." = FIELD("Entry No.");
            //     DataItemTableView = Sorting("Cust. Ledger Entry No.", "Posting Date") where("Document Type" = filter(1),
            //                                  "Entry Type" = filter('Application'),
            //                                  Unapplied = const(false));


            //     column(PaymentNo; DetCustLedgEntry."Document No.")
            //     {
            //     }


            //     column(AmountLCY; DetCustLedgEntry."Amount (LCY)")
            //     {
            //     }


            // }
            trigger OnPreDataItem()
            begin
                GLFilter := "Cust. Ledger Entry".GetFilters;
            end;

            trigger OnAfterGetRecord()
            begin
                if Customer.GET("Cust. Ledger Entry"."Sell-to Customer No.") then;
                if InvoiceHeader.GET("Cust. Ledger Entry"."Document No.") then;
            end;



        }
    }




    var
        GLFilter: Text;

        CompanyInfo: Record "Company Information";
        Customer: Record Customer;
        InvoiceHeader: Record "Sales Invoice Header";
    // Customer2: Record Customer;
    // StartDateFilter: Date;
    // EndtDateFilter: Date;
    // SalespersonInvoice: code[20];
    // SalespersonInvoice2: code[20];
    // salesPersonPayment2: Code[20];
    // CustomerFilter: Code[20];
    // SalesPersonManFilter: Code[20];
    // SalesPersonCodeFilter: Code[20];
    // InvoiceNo: Code[20];
    // InvoiceNo2: Code[20];
    // CustToAppear: Boolean;
    // TotalPayment: Decimal;
    // TotalCHQ_TRT: Decimal;
    // TotalBycustomer: Decimal;
    // PaymentAmount2: Decimal;
    // InvoicesTotal3: Decimal;

}


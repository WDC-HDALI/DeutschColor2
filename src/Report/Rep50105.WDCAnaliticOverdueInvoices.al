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
            RequestFilterFields = "Sell-to Customer No.", "Salesperson Code", "Posting Date", "Due Date";
            DataItemTableView = SORTING("Customer No.", "Posting Date", "Currency Code") order(ascending)
                                           where("Document Type" = filter(2 | 3),
                                           "Sell-to Customer No." = filter('C*'));
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
            column(CustNo; "Cust. Ledger Entry"."Customer No.")
            {
            }

            column(CustName; customer.Name)
            {
            }

            column(SalespersonInv; "Cust. Ledger Entry"."Salesperson Code")
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
            column(LineNo; LineNo)
            {

            }
            column(OnTime; OnTime)
            {

            }
            column(Sup30days; Sup30days)
            {

            }
            column(Sup60days; Sup60days)
            {

            }
            column(Sup90days; Sup90days)
            {

            }
            column(Sup120days; Sup120days)
            {

            }

            trigger OnPreDataItem()
            begin
                CompanyInfo.get;
                GLFilter := "Cust. Ledger Entry".GetFilters;
                LineNo := 0;
                FromDate := "Cust. Ledger Entry".GetRangeMin("Posting Date");
                ToDate := "Cust. Ledger Entry".GetRangeMax("Posting Date");
            end;

            trigger OnAfterGetRecord()
            begin
                "Cust. Ledger Entry".CalcFields("Remaining Amt. (LCY)");
                LineNo += 1;
                if Customer.GET("Cust. Ledger Entry"."Sell-to Customer No.") then;
                if InvoiceHeader.GET("Cust. Ledger Entry"."Document No.") then
                    if "Cust. Ledger Entry"."Remaining Amt. (LCY)" <> "Cust. Ledger Entry"."Amount (LCY)" then
                        GetOverdueDay(InvoiceHeader."No.", InvoiceHeader."Due Date", "Cust. Ledger Entry"."Entry No.");
            end;

        }
    }


    procedure GetOverdueDay(pInvoiceNo: code[20]; pDueInvDate: Date; pCustLedgEntryNo: Integer)
    var
        lDetCustLedg: Record "Detailed Cust. Ledg. Entry";
        lTotalAmt: Decimal;
        NbOverDueDays: Integer;
    begin
        lDetCustLedg.Reset();
        lDetCustLedg.SetRange("Cust. Ledger Entry No.", pCustLedgEntryNo);
        lDetCustLedg.SetRange("Document Type", lDetCustLedg."Document Type"::Payment);
        lDetCustLedg.SetRange("Entry Type", lDetCustLedg."Entry Type"::Application);
        If lDetCustLedg.FindFirst() then
            repeat
                NbOverDueDays := CalcOverDueDay(pDueInvDate, lDetCustLedg."Document No.");
                if NbOverDueDays <= 0 Then
                    OnTime += lDetCustLedg."Amount (LCY)"
                else
                    if (0 < NbOverDueDays) and (NbOverDueDays <= 30) then
                        Sup30days += lDetCustLedg."Amount (LCY)"
                    else
                        if (30 < NbOverDueDays) and (NbOverDueDays <= 60) then
                            Sup60days += lDetCustLedg."Amount (LCY)"
                        else
                            if (60 < NbOverDueDays) and (NbOverDueDays <= 90) then
                                Sup90days += lDetCustLedg."Amount (LCY)"
                            Else
                                if (NbOverDueDays <= 120) then
                                    Sup120days += lDetCustLedg."Amount (LCY)";
            until lDetCustLedg.Next() = 0;

    end;

    procedure CalcOverDueDay(pInvDueDate: Date; pPaymentNo: code[20]): Integer
    begin
        exit(pInvDueDate - pPaymentRefDate)
    end;

    var
        GLFilter: Text;
        CompanyInfo: Record "Company Information";
        Customer: Record Customer;
        InvoiceHeader: Record "Sales Invoice Header";
        LineNo: Integer;
        FromDate: Date;
        ToDate: Date;
        OnTime: Decimal;
        Sup30days: Decimal;
        Sup60days: Decimal;
        Sup90days: Decimal;
        Sup120days: Decimal;

}


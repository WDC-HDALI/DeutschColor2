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
                if InvoiceHeader.GET("Cust. Ledger Entry"."Document No.") then;
            end;

        }
    }




    var
        GLFilter: Text;
        CompanyInfo: Record "Company Information";
        Customer: Record Customer;
        InvoiceHeader: Record "Sales Invoice Header";
        LineNo: Integer;
        FromDate: Date;
        ToDate: Date;

}


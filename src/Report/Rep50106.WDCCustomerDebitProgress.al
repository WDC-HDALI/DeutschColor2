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
            DataItemTableView = sorting("No.") where("No." = filter('C*'));
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

            column(PrviousBalance; GetPrviousBalance(customer."No.", FromDate))
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
                Customer.SetRange("No.", CustomerFilter);
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
                    field(CustomerFilter; CustomerFilter)
                    {
                        ApplicationArea = all;
                        Caption = 'Customer';
                        TableRelation = Customer where("No." = filter('C*'));
                    }
                    field(SalesPersonManFilter; SalesPersonManFilter)
                    {
                        ApplicationArea = all;
                        Caption = 'Sales Person Manager';
                        TableRelation = "Salesperson/Purchaser";
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
    begin
        lDetCustLedgEntry.Reset();
        lDetCustLedgEntry.SetCurrentKey("Customer No.", "Entry Type", "Posting Date", "Initial Document Type");
        lDetCustLedgEntry.SetRange("Customer No.", pCustNo);
        If lDetCustLedgEntry.FindFirst() Then
            lDetCustLedgEntry.CalcSums("Amount (LCY)");
        exit(lDetCustLedgEntry."Amount (LCY)");
    end;

    procedure GetInvoiceAndCrdMemo(pCustNo: code[20]; pStartDate: Date; pEndDate: Date): Decimal
    var
        lCustLedgEnt: record 21;
    begin
        lCustLedgEnt.Reset();
        lCustLedgEnt.SetFilter("Document Type", '%1|%2', lCustLedgEnt."Document Type"::"Credit Memo", lCustLedgEnt."Document Type"::Invoice);
    end;

    procedure GetShippedNotInvoiced(pCustNo: code[20]; pStartDate: Date; pEndDate: Date): Decimal
    begin

    end;

    procedure GetReturnedNotInvoiced(pCustNo: code[20]; pStartDate: Date; pEndDate: Date): Decimal
    begin

    end;

    procedure GetPayment(pCustNo: code[20]; pStartDate: Date; pEndDate: Date): Decimal
    begin

    end;

    procedure GetImpaid(pCustNo: code[20]; pStartDate: Date; pEndDate: Date): Decimal
    begin

    end;

    procedure GetTotalChqAndTrtByManager(pCustNo: code[20]; pStartDate: Date; pEndDate: Date): Decimal
    begin

    end;

    procedure GetCashByManager(pCustNo: code[20]; pStartDate: Date; pEndDate: Date): Decimal
    begin

    end;

    procedure GetChqAndTrtWaitToEncaise(pCustNo: code[20]; pStartDate: Date; pEndDate: Date): Decimal
    begin

    end;

    var
        GLFilter: Text;
        CompanyInfo: Record "Company Information";
        InvoiceHeader: Record "Sales Invoice Header";
        LineNo: Integer;
        FromDate: Date;
        ToDate: Date;
        CustomerFilter: Code[20];
        SalesPersonManFilter: Code[20];


}


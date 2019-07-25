tableextension 75000 AdiutoFieldsSalesHeader extends "Sales Header"
{
    fields
    {
        field(75000; "Barcode Delivery Document"; Code[50])
        {
            CaptionML = ENU = 'Barcode Delivery Document', ITA = 'Barcode DDT';
            Description = 'ADI';
        }
        field(75001; "Barcode Invoice Document"; Code[50])
        {
            CaptionML = ENU = 'Barcode Invoice Document', ITA = 'Barcode Fattura';
            Description = 'ADI';
        }
        field(75002; "Electronic Document Status"; Code[50])
        {
            FieldClass = FlowField;
            CaptionML = ENU = 'Electronic Document Status', ITA = 'Stato documento elettronico';
            CalcFormula = Lookup ("Adiuto Electr. Doc.".Status WHERE ("Source No." = CONST (36),
                "Document No." = FIELD ("No."),
                "IdUnivoco" = FIELD ("Barcode Delivery Document")));
            Description = 'ADI';
        }
        field(75003; "Internal Change Note"; Boolean)
        {
            CaptionML = ENU = 'Internal Change Note', ITA = 'Nota di Variazione Interna';
            Description = 'ADI';
        }
        field(75004; "Duty Stamp Amount"; Decimal)
        {
            CaptionML = ENU = 'Duty Stamp Amount', ITA = 'Importo bollo';
            Description = 'ADI';
        }
    }
}

tableextension 75001 AdiutoFieldsSalesShipHeader extends "Sales Shipment Header"
{
    fields
    {
        field(75000; "Barcode Delivery Document"; Code[50])
        {
            CaptionML = ENU = 'Barcode Delivery Document', ITA = 'Barcode DDT';
            Description = 'ADI';
        }
        field(75001; "Barcode Invoice Document"; Code[50])
        {
            CaptionML = ENU = 'Barcode Invoice Document', ITA = 'Barcode Fattura';
            Description = 'ADI';
        }
        field(75002; "Electronic Document Status"; Code[50])
        {
            FieldClass = FlowField;
            CaptionML = ENU = 'Electronic Document Status', ITA = 'Stato documento elettronico';
            CalcFormula = Lookup ("Adiuto Electr. Doc.".Status WHERE ("Source No." = CONST (110),
                "Document No." = FIELD ("No."),
                "IdUnivoco" = FIELD ("Barcode Delivery Document")));
            Description = 'ADI';
        }
        field(75003; "Internal Change Note"; Boolean)
        {
            CaptionML = ENU = 'Internal Change Note', ITA = 'Nota di Variazione Interna';
            Description = 'ADI';
        }
        field(75004; "Duty Stamp Amount"; Decimal)
        {
            CaptionML = ENU = 'Duty Stamp Amount', ITA = 'Importo bollo';
            Description = 'ADI';
        }
    }
}
tableextension 75002 AdiutoFieldsSalesInvoiceHeader extends "Sales Invoice Header"
{
    fields
    {
        field(75000; "Barcode Delivery Document"; Code[50])
        {
            CaptionML = ENU = 'Barcode Delivery Document', ITA = 'Barcode DDT';
            Description = 'ADI';
        }
        field(75001; "Barcode Invoice Document"; Code[50])
        {
            CaptionML = ENU = 'Barcode Invoice Document', ITA = 'Barcode Fattura';
            Description = 'ADI';
        }
        field(75002; "Electronic Document Status"; Code[50])
        {
            FieldClass = FlowField;
            CaptionML = ENU = 'Electronic Document Status', ITA = 'Stato documento elettronico';
            CalcFormula = Lookup ("Adiuto Electr. Doc.".Status WHERE ("Source No." = CONST (112),
                "Document No." = FIELD ("No."),
                "IdUnivoco" = FIELD ("Barcode Delivery Document")));
            Description = 'ADI';
        }
        field(75003; "Internal Change Note"; Boolean)
        {
            CaptionML = ENU = 'Internal Change Note', ITA = 'Nota di Variazione Interna';
            Description = 'ADI';
        }
        field(75004; "Duty Stamp Amount"; Decimal)
        {
            CaptionML = ENU = 'Duty Stamp Amount', ITA = 'Importo bollo';
            Description = 'ADI';
        }
    }
}

tableextension 75003 AdiutoFieldsSalesCrMemoHeader extends "Sales Cr.Memo Header"
{
    fields
    {
        field(75000; "Barcode Delivery Document"; Code[50])
        {
            CaptionML = ENU = 'Barcode Delivery Document', ITA = 'Barcode DDT';
            Description = 'ADI';
        }
        field(75001; "Barcode Invoice Document"; Code[50])
        {
            CaptionML = ENU = 'Barcode Invoice Document', ITA = 'Barcode Fattura';
            Description = 'ADI';
        }
        field(75002; "Electronic Document Status"; Code[50])
        {
            FieldClass = FlowField;
            CaptionML = ENU = 'Electronic Document Status', ITA = 'Stato documento elettronico';
            CalcFormula = Lookup ("Adiuto Electr. Doc.".Status WHERE ("Source No." = CONST (114),
                "Document No." = FIELD ("No."),
                "IdUnivoco" = FIELD ("Barcode Delivery Document")));
            Description = 'ADI';
        }
        field(75003; "Internal Change Note"; Boolean)
        {
            CaptionML = ENU = 'Internal Change Note', ITA = 'Nota di Variazione Interna';
            Description = 'ADI';
        }
        field(75004; "Duty Stamp Amount"; Decimal)
        {
            CaptionML = ENU = 'Duty Stamp Amount', ITA = 'Importo bollo';
            Description = 'ADI';
        }
    }
}

tableextension 75004 AdiutoFieldsSalesHeaderArchive extends "Sales Header Archive"
{
    fields
    {
        field(75000; "Barcode Delivery Document"; Code[50])
        {
            CaptionML = ENU = 'Barcode Delivery Document', ITA = 'Barcode DDT';
            Description = 'ADI';
        }
        field(75001; "Barcode Invoice Document"; Code[50])
        {
            CaptionML = ENU = 'Barcode Invoice Document', ITA = 'Barcode Fattura';
            Description = 'ADI';
        }
        field(75002; "Electronic Document Status"; Code[50])
        {
            FieldClass = FlowField;
            CaptionML = ENU = 'Electronic Document Status', ITA = 'Stato documento elettronico';
            CalcFormula = Lookup ("Adiuto Electr. Doc.".Status WHERE ("Source No." = CONST (36),
                "Document No." = FIELD ("No."),
                "IdUnivoco" = FIELD ("Barcode Delivery Document")));
            Description = 'ADI';
        }
        field(75003; "Internal Change Note"; Boolean)
        {
            CaptionML = ENU = 'Internal Change Note', ITA = 'Nota di Variazione Interna';
            Description = 'ADI';
        }
        field(75004; "Duty Stamp Amount"; Decimal)
        {
            CaptionML = ENU = 'Duty Stamp Amount', ITA = 'Importo bollo';
            Description = 'ADI';
        }
    }
}

tableextension 75005 AdiutoFieldsReturnRcptHeader extends "Return Receipt Header"
{
    fields
    {
        field(75000; "Barcode Delivery Document"; Code[50])
        {
            CaptionML = ENU = 'Barcode Delivery Document', ITA = 'Barcode DDT';
            Description = 'ADI';
        }
        field(75001; "Barcode Invoice Document"; Code[50])
        {
            CaptionML = ENU = 'Barcode Invoice Document', ITA = 'Barcode Fattura';
            Description = 'ADI';
        }
        field(75002; "Electronic Document Status"; Code[50])
        {
            FieldClass = FlowField;
            CaptionML = ENU = 'Electronic Document Status', ITA = 'Stato documento elettronico';
            CalcFormula = Lookup ("Adiuto Electr. Doc.".Status WHERE ("Source No." = CONST (6660),
                "Document No." = FIELD ("No."),
                "IdUnivoco" = FIELD ("Barcode Delivery Document")));
            Description = 'ADI';
        }
        field(75003; "Internal Change Note"; Boolean)
        {
            CaptionML = ENU = 'Internal Change Note', ITA = 'Nota di Variazione Interna';
            Description = 'ADI';
        }
        field(75004; "Duty Stamp Amount"; Decimal)
        {
            CaptionML = ENU = 'Duty Stamp Amount', ITA = 'Importo bollo';
            Description = 'ADI';
        }
    }
}
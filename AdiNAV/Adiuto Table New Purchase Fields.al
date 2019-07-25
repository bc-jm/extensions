tableextension 75100 AdiutoFieldsPurchaseHeader extends "Purchase Header"
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
            CalcFormula = Lookup ("Adiuto Electr. Doc.".Status WHERE ("Source No." = CONST (38),
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

tableextension 75101 AdiutoFieldsPurchaseRcptHeader extends "Purch. Rcpt. Header"
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
tableextension 75102 AdiutoFieldsPurchInvoiceHeader extends "Purch. Inv. Header"
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

tableextension 75103 AdiutoFieldsPurchCrMemoHeader extends "Purch. Cr. Memo Hdr."
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

tableextension 75104 AdiutoFieldsPurchHeaderArchive extends "Purchase Header Archive"
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
            CalcFormula = Lookup ("Adiuto Electr. Doc.".Status WHERE ("Source No." = CONST (38),
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

tableextension 75105 AdiutoFieldsReturnShipHeader extends "Return Shipment Header"
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
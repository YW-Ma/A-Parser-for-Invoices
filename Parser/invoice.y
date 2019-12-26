%{
  #include <cstdio>
  #include <iostream>
  using namespace std;

  // stuff from flex that bison needs to know about:
  int yylex();
  int yyparse();
  extern FILE *yyin;
  extern FILE *FCustomer;
  extern FILE *FInvoice;
  extern FILE *FItems;
  extern int line_num;
  extern int invoice_counter;
  // global variables:
  // bussiness name:
  extern char BUSSINESS_NAME[128];
  // Customer Information global variables:
  extern bool in_the_list;
  extern int CUSTOMER_ID;
  extern int CUSTOMER_ID_LIST[128];
  extern int CUSTOMER_COUNTER;
  extern char CUSTOMER_NAME[128];
  extern int CUSTOMER_ROAD_NUMBER;
  extern char CUSTOMER_ROAD[128];
  extern char CUSTOMER_CITY[128];
  extern char CUSTOMER_COUNTRY[128];
  extern int CUSTOMER_PHONE;
  // Invoice Information global variables:
  extern char INV_ID_AREA[48];
  extern int INV_ID_NUMBER;
  extern int INV_ISSUE_DD;
  extern int INV_ISSUE_MM;
  extern int INV_ISSUE_YYYY;
  extern int INV_PON_1;
  extern int INV_PON_2;
  extern int INV_DUE_DD;
  extern int INV_DUE_MM;
  extern int INV_DUE_YYYY;
  extern int INV_TERM_TYPE;
  extern float INV_SUBTOTAL;
  extern float INV_VAT;
  extern float INV_TOTAL;
  // Amounts for total price
  extern int PRODUCT_AMOUNT;
  void yyerror(const char *s);
%}

%union {
  int ival;
  float fval;
  char *sval;
}

// define the constant-string tokens:
%token INVOICE TO
%token INVOICE_NUM DATE ORDER_NUM DUE TERM NET
%token ID DESCRIPTION QTY UNIT_PRICE AMOUNT
%token TABLE DASH
%token SUBTOTAL VAT TOTAL
%token ENDL

// define the "terminal symbol" token types I'm going to use (in CAPS
// by convention), and associate each with a field of the union:
%token <ival> INT
%token <fval> FLOAT
%token <sval> STRING

%%
// the first rule defined is the highest-level rule, which in our
// case is just the concept of a whole "invoice file":
invoice:
  invoice Header OrderContent Footer
  | Header OrderContent Footer
  ;


Header: 
  INVOICE ENDLS BussinessName CustomerInfo InvoiceInfo;
BussinessName: 
  STRING ENDLS{
    sprintf(BUSSINESS_NAME,"%s",$1);
  };
CustomerInfo: 
  TO ENDL CustomerID CustomerName Address City Country Phone;
CustomerID: 
  INT ENDL
  {
    CUSTOMER_ID=$1;
  };
CustomerName: 
  STRING ENDL{
    sprintf(CUSTOMER_NAME,"%s",$1);
    free($1);
  };
Address: 
  RoadNumber Road;
RoadNumber: 
  INT
  {
    CUSTOMER_ROAD_NUMBER=$1;   
  };
Road: 
  STRING ENDLS
  {
    sprintf(CUSTOMER_ROAD,"%s",$1);
    free($1);
  };
City: 
  STRING ENDL{
    sprintf(CUSTOMER_CITY,"%s",$1);
    free($1);
  };
Country: 
  STRING ENDL
  {
    sprintf(CUSTOMER_COUNTRY,"%s",$1);
    free($1);
  };
Phone: 
  INT ENDLS
  {
    CUSTOMER_PHONE=$1;
  };
InvoiceInfo: 
  InvoiceID IssueDate OrderNumber DueDate Term;
InvoiceID: 
  INVOICE_NUM TABLE STRING DASH INT ENDLS
  {
    sprintf(INV_ID_AREA,"%s",$3);
    INV_ID_NUMBER=$5;
    invoice_counter=invoice_counter+1;
    fprintf(FInvoice,"%s-%d\t",INV_ID_AREA,INV_ID_NUMBER);
    fprintf(FInvoice,"%d\t",CUSTOMER_ID);
    fprintf(FInvoice,"%s\t",BUSSINESS_NAME);
    //print a new customer ID, if the customer of this invoice is not in the list.
    //IF ID IS NOT IN THE LIST, THEN COUNTER ++
    for(int i=0;i<128;i++)
    {
      in_the_list = (CUSTOMER_ID==CUSTOMER_ID_LIST[i]);
      if(in_the_list)break;
    }
    if(!in_the_list)
    {
      CUSTOMER_ID_LIST[CUSTOMER_COUNTER]=CUSTOMER_ID;
      CUSTOMER_COUNTER++;
      fprintf(FCustomer,"%d\t%s\t%d\t%s\t%s\t%s\t%d\n",CUSTOMER_ID,CUSTOMER_NAME,CUSTOMER_ROAD_NUMBER,CUSTOMER_ROAD,CUSTOMER_CITY,CUSTOMER_COUNTRY,CUSTOMER_PHONE);
    }
  };
IssueDate:
  DATE TABLE INT DASH INT DASH INT ENDLS{
    INV_ISSUE_DD=$3;
    INV_ISSUE_MM=$5;
    INV_ISSUE_YYYY=$7;
    fprintf(FInvoice,"%02d-%02d-%04d\t",INV_ISSUE_DD,INV_ISSUE_MM,INV_ISSUE_YYYY);
  };
OrderNumber:
  ORDER_NUM TABLE INT DASH INT ENDLS{
    INV_PON_1=$3;
    INV_PON_2=$5;
    fprintf(FInvoice,"%03d-%04d\t",INV_PON_1,INV_PON_2);
  };
DueDate:
  DUE TABLE INT DASH INT DASH INT ENDLS
  {
    INV_DUE_DD=$3;
    INV_DUE_MM=$5;
    INV_DUE_YYYY=$7;
    fprintf(FInvoice,"%02d-%02d-%04d\t",INV_DUE_DD,INV_DUE_MM,INV_DUE_YYYY);
  };
Term:
  TERM TABLE NET INT ENDLS{
    INV_TERM_TYPE=$4;
    fprintf(FInvoice,"Net - %2d\t",INV_TERM_TYPE);
  };


OrderContent: 
  EntryHeader Entries;
EntryHeader:
  ID TABLE DESCRIPTION TABLE QTY TABLE UNIT_PRICE TABLE AMOUNT ENDLS ;
Entries:
  Entries Entry
  | Entry;
Entry:
  INT TABLE STRING TABLE INT TABLE FLOAT TABLE FLOAT ENDLS 
  {
    fprintf(FItems,"%d\t%s\t%d\t%.2lf\t%.2lf\n",$1,$3,$5,$7,$9);
    //Check: Unit Price * Quantity = Amount
    if((($5*$7-$9)<-0.001)||(($5*$7-$9)>0.001))
    {
      printf("Warning: Amount Price in the No.%d Invoice is incorrect.\nIncorrect Product Name:%s\n",invoice_counter,$3);
    }
    PRODUCT_AMOUNT+=$9;
    free($3);
  };


Footer:
  Subtotal Tax Total{
    cout << "done with No."<< invoice_counter <<" invoice file to "<< CUSTOMER_NAME << endl;
  };
Subtotal:
  SUBTOTAL TABLE FLOAT ENDLS
  {
    INV_SUBTOTAL=$3;
    fprintf(FInvoice,"%.2lf\t",INV_SUBTOTAL);
    //Check:      The sum of amounts of items = Subtotal
  };
Tax:
  VAT TABLE FLOAT ENDLS
  {
    INV_VAT=$3;
    fprintf(FInvoice,"%.2lf\t",INV_VAT);
  };
Total:
  TOTAL TABLE FLOAT ENDLS
  {
    INV_TOTAL=$3;
    fprintf(FInvoice,"%.2lf\n",INV_TOTAL);
    //Check:      subtotal + vat = total
    float diff = (INV_SUBTOTAL+INV_VAT)-INV_TOTAL;
    if(diff<-0.01||diff>0.01) printf("Warning: Invalid Total Price in No.%d Invoice.\n",invoice_counter);
  };
ENDLS:
  ENDLS ENDL
  | ENDL ;
%%

int main(int, char**) {
  // open a file handle to a particular file:
  FILE *myfile = fopen("invoice.samples.txt", "r");
  FCustomer=fopen("Tables//Customer_Info.tab","w");
  FInvoice=fopen("Tables//Invoice_Info.tab","w");
  FItems=fopen("Tables//Items.tab","w");
  // make sure it's valid:
  if (!myfile) {
    cout << "I can't open invoice.samples.txt!" << endl;
    return -1;
  }
  if (!FCustomer) {
    cout << "I can't open FCustomer!" << endl;
    return -1;
  }
  if (!FInvoice) {
    cout << "I can't open FInvoice!" << endl;
    return -1;
  }
  if (!FItems) {
    cout << "I can't open FItems!" << endl;
    return -1;
  }
  fprintf(FCustomer,"CustomerID\tCustomerName\tRoadNumber\tRoad\tCity\tCountry\tPhone\n");
  fprintf(FInvoice,"InvoiceID\tCustomerID\tBusinessName\tIssueDate\tOrderNumber\tDueDate\tTerm\tSubtotal\tVAT\tTOTAL\n");
  fprintf(FItems,"ProductID\tProductName\tQuantity\tUnit Price\tAmount\n");
  // set lex to read from it instead of defaulting to STDIN:
  yyin = myfile;

  // parse through the input until there is no more:

  do {
    yyparse();
  } while (!feof(yyin));
  fclose(FCustomer);
  fclose(FInvoice);
  fclose(FItems);
}

void yyerror(const char *s) {
  cout << "Parse error on line " << line_num << "!  Message: " << s << endl;
  // might as well halt now:
  exit(-1);
}
%{
  #include <cstdio>
  #include <iostream>
  #include <ctime>
  using namespace std;

  // 1. Functions and Variables from Flex
  // 1.1 Functions
   // Declare stuff from Flex that Bison needs to know about:
  extern int yylex();
  extern int yyparse();
  extern void yyerror(const char *s);
  // 1.2 Variables
  extern FILE *yyin;
  extern FILE *FCustomer;
  extern FILE *FInvoice;
  extern FILE *FItems;
  extern int line_num;
  extern int invoice_counter;
  //  (1) Bussiness name:
  extern char BUSSINESS_NAME[128];
  //  (2) Customer Information global variables:
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
  //  (3) Invoice Information global variables:
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
  //  (4) Amounts for total price
  extern int PRODUCT_AMOUNT;

%}
//2. Define tokens
//2.2 define the constant-string tokens:
%token INVOICE TO
%token INVOICE_NUM DATE ORDER_NUM DUE TERM NET
%token ID DESCRIPTION QTY UNIT_PRICE AMOUNT
%token TABLE DASH
%token SUBTOTAL VAT TOTAL
%token ENDL
//2.2 define tokens for int, float, string
%union {
  int ival;
  float fval;
  char *sval;
}
%token <ival> INT
%token <fval> FLOAT
%token <sval> STRING

%%
//3. Definition of Production Rules

//All Invoices
invoice:
  invoice Header Body Footer
  | Header Body Footer
  ;

//Part 1: Header
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
//Phone number in USA has 8 digits. (therefore it can be stored within an integer)
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
    //check
    if($7>2020) printf("[Warning] Invalid IssueDate %d of No.%d Invoice.\n",$7,invoice_counter);
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
    //check
    if($7>2020) printf("[Warning] Invalid DueDate %d of No.%d Invoice.\n",$7,invoice_counter);
    fprintf(FInvoice,"%02d-%02d-%04d\t",INV_DUE_DD,INV_DUE_MM,INV_DUE_YYYY);
  };
//Term refers to the Terms of payment
//for example - Net-15 means "the net amount is expected to be paid in full by the buyer within 15 days"
Term:
  TERM TABLE NET INT ENDLS{
    INV_TERM_TYPE=$4;
    fprintf(FInvoice,"Net - %2d\t",INV_TERM_TYPE);
  };

//Part 2: Entries of this order
Body: 
  EntryHeader Entries;
EntryHeader:
  ID TABLE DESCRIPTION TABLE QTY TABLE UNIT_PRICE TABLE AMOUNT ENDLS ;
Entries:
  Entries Entry
  | Entry;
Entry:
  INT TABLE STRING TABLE INT TABLE FLOAT TABLE FLOAT ENDLS 
  {
    char tInvoiceID[128]={0};
    sprintf(tInvoiceID,"%s-%d\t",INV_ID_AREA,INV_ID_NUMBER);
    fprintf(FItems,"%d\t%s\t%d\t%.2lf\t%.2lf\t%s\n",$1,$3,$5,$7,$9,tInvoiceID);
    //Semantic Check: Unit Price * Quantity = Amount
    if((($5*$7-$9)<-0.001)||(($5*$7-$9)>0.001))
    {
      printf("[Warning]: Amount Price in the No.%d Invoice is incorrect. Incorrect Product Name:%s\n",invoice_counter,$3);
    }
    PRODUCT_AMOUNT+=$9;
    free($3);
  };

//Part 3: Footer
Footer:
  Subtotal Tax Total{
    cout << "[Done] with No."<< invoice_counter <<" invoice file to "<< CUSTOMER_NAME << endl;
    cout << "-------------------------------" <<endl;
  };
Subtotal:
  SUBTOTAL TABLE FLOAT ENDLS
  {
    INV_SUBTOTAL=$3;
    fprintf(FInvoice,"%.2lf\t",INV_SUBTOTAL);
    //Semantic Check: The sum of amounts of items = Subtotal
  };
Tax:
  VAT TABLE FLOAT ENDLS
  {
    INV_VAT=$3;
    fprintf(FInvoice,"%.2lf\t",INV_VAT);
    float diff = (INV_SUBTOTAL*0.05)-INV_VAT;
    if(diff<-0.01||diff>0.01) printf("[Warning]: Tax amount(with rate 5%) in No.%d Invoice is incorrect. Tax should be %.2lf.\n",invoice_counter,INV_SUBTOTAL*0.05);
  };
Total:
  TOTAL TABLE FLOAT ENDLS
  {
    INV_TOTAL=$3;
    fprintf(FInvoice,"%.2lf\n",INV_TOTAL);
    //Semantic Check:  subtotal + vat = total
    float diff = (INV_SUBTOTAL+INV_VAT)-INV_TOTAL;
    float total_price = (INV_SUBTOTAL+INV_VAT);
    if(diff<-0.01||diff>0.01) printf("[Warning]: Invalid Total Price in No.%d Invoice. Total price should be %.2lf.\n",invoice_counter,total_price);
  };

//Endline
ENDLS:
  ENDLS ENDL
  | ENDL ;
%%

int main(int, char**) {
  // timer
  //clock_t start,end;
  // instruction: 
  cout << "This is a parser for invoices. \nPlease enter invoice file: ";\
  char InvoiceFile[128]={0};
  cin >> InvoiceFile;
  //1.FILE I/O
  //1.2 Open the file containing all invoices
  FILE *FSamples = fopen(InvoiceFile, "r");
  //1.2 Create tables for loading results
  FCustomer=fopen("Tables//Customer_Info.tab","w");
  FInvoice=fopen("Tables//Invoice_Info.tab","w");
  FItems=fopen("Tables//Items.tab","w");
  //1.3 Make sure all files are valid
  if (!FSamples) {
    cout << "I can't open" << InvoiceFile << endl;
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
  //1.4 Write Table Headers
  fprintf(FCustomer,"CustomerID\tCustomerName\tRoadNumber\tRoad\tCity\tCountry\tPhone\n");
  fprintf(FInvoice,"InvoiceID\tCustomerID\tBusinessName\tIssueDate\tOrderNumber\tDueDate\tTerm\tSubtotal\tVAT\tTOTAL\n");
  fprintf(FItems,"ProductID\tProductName\tQuantity\tUnit Price\tAmount\tInvoiceID\n");
  //1.5 Set Flex to read from invoice samples instead of defaulting to STDIN:
  yyin = FSamples;

  //2. Parse through the input until there is no more:
//  start = clock();        
  do {
    yyparse();
  } while (!feof(yyin));
//  end = clock();
//  double endtime=(double)(end-start)/CLOCKS_PER_SEC;     //uncomment to count time
//  cout << "total time:" << endtime << "ms" <<endl;
  fclose(FCustomer);
  fclose(FInvoice);
  fclose(FItems);
}

// Error Processing
void yyerror(const char *s) {
  cout << "[Error] parser error on line " << line_num << "! " << s << endl;
  exit(-1);
}
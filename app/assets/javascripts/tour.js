// Instance the tour
$(document).ready(function(){
var tour = new Tour({
  steps: [
  
    
  
  {
    element: "#income_menu_tour",
    title: "Record Your Income",
    content: "Create invoices, record receipts and manage customers from this menu."
  },
  {
    element: "#expenses_menu_tour",
    title: "Track Your Expenses",
    content: "Track day to day expenses, payments and vendors from this menu."
  },
  {
    element: "#banking_menu_tour",
    title: "Banking ",
    content: "Records your bank withdrawals, deposits and transfers from this menu."
  },
  {
    element: "#accounting_menu_tour",
    title: "General Accounting",
    content: "View your chart of accounts, manage taxes or invite an advisor from this menu."
  },
  {
    element: "#inventory_menu_tour",
    title: "Manage Inventory",
    content: "This menu shows the list of products/services. You can also manage your stock transfer and wastages"
  },
  {
    element: "#payroll_menu_tour",
    title: "Your HR section",
    content: "Create employees and process monthly payroll in minutes from this menu. "
  },
  {
    element: "#task_menu_tour",
    title: "Get productive",
    content: "Quickly access your tasks, projects, documents and timesheet from here."
  },
  {
    element: "#Intercom",
    title: "Instant Support",
    content: "Send a message to our experts instantly by clicking this button."
  },
  {
    element: "#profile_tour",
    title: "Setting",
    content: $('<p />').html("All your settings and preferences are here<br /><br /><a href='/products/new' class='btn btn-info btn-xs'>Lets add a new product/service now</a>"),
    placement: "left"
  }
]});

    $("#btn_tour").click(function(){
      tour.init();
      tour.restart();
        tour.start(true);
    }); 
});






  


  


  
  

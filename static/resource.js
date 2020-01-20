
var app = new Framework7({
    id: 'com.arc.creator',
    root: '#app',
    theme: "auto",
    name: 'Resource Creator',
    routes: [
      {
        name: 'admin',
        path: '/admin',
        pageName: 'admin'
      }
    ]
  });
  
  var mainView = app.views.create('.view-main', {
    stackPages: true,
    on: {
      pageInit: function (data) {
        loadMachines(data.pageEl.querySelector(".list > ul"));
      }
    }
  });
  
  var router = mainView.router;
  
  function loadMachines(list) {
    var req = new XMLHttpRequest();
    req.addEventListener("load", () => {
      if (req.status === 200) {
          debugger;
        // var templates = JSON.parse(req.responseText);
        // templates.forEach(element => {
        //   var template = document.createElement('li');
        //   template.className = "arm-template";
        //   template.innerHTML = '<a href="#" class="item-link"><div class="item-content"><div class="item-media"><img style="height: 32px;" src="template/' + element.path + '/icon"></div><div class="item-inner">' + element.name + '</div></div></a>';
        //   list.appendChild(template);
        //   template.onclick = () => {
        //     router.navigate({name: 'template', params: { path: element.path, name: element.name }})
        //   }
        // });
      }
    });
    req.open("GET", 'vms');
    req.send();
  }
  
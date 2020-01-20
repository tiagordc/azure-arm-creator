
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
        loadMachines(data.pageEl.querySelector(".page-content"));
      }
    }
  });
  
  var router = mainView.router;
  
  function loadMachines(content) {
    var req = new XMLHttpRequest();
    req.addEventListener("load", () => {
      if (req.status === 200) {
        var machines = JSON.parse(req.responseText);
        machines.forEach(element => {

          var cardItem = document.createElement('div');
          cardItem.className = 'card';
          content.appendChild(cardItem);

          var cardHeader = document.createElement('div');
          cardHeader.className = 'card-header';
          cardHeader.innerText = element.tags && element.tags['arm-name'] ? element.tags['arm-name'] : element.name;
          cardItem.appendChild(cardHeader);

          var status = document.createElement('div');
          status.className = 'powerState';
          status.title = element.status;
          cardHeader.appendChild(status);

          var statusColor = document.createElement('span');
          status.appendChild(statusColor);

          switch (element.status) {
            case 'running':
              statusColor.style.backgroundColor = 'green';
              break;
            case 'stopped':
            case 'stopping':
            case 'deallocated':
            case 'deallocating':
              statusColor.style.backgroundColor = 'red';
              break;
            case 'starting':
              statusColor.style.backgroundColor = 'yellow';
              break;
          }

          var cardContent = document.createElement('div');
          cardContent.className = 'card-content card-content-padding';
          cardItem.appendChild(cardContent);

          if (element.tags && element.tags['arm-description']) {
            var description = document.createElement('div');
            description.innerText = element.tags['arm-description'];
            cardContent.appendChild(description);
          }

          if (element.public && element.public instanceof Array && element.public.length > 0) {
            var ips = document.createElement('div');
            ips.style.paddingTop = '10px';
            ips.innerHTML = "Public IPs:"
            var list = document.createElement('ul');
            ips.appendChild(list);
            element.public.forEach(ip => {
              var listItem = document.createElement('li');
              listItem.innerText = ip;
              list.appendChild(listItem);
            });
            cardContent.appendChild(ips);
          }

          if (element.private && element.private instanceof Array && element.private.length > 0) {
            var ips = document.createElement('div');
            ips.style.paddingTop = '10px';
            ips.innerHTML = "Private IPs:"
            var list = document.createElement('ul');
            ips.appendChild(list);
            element.private.forEach(ip => {
              var listItem = document.createElement('li');
              listItem.innerText = ip;
              list.appendChild(listItem);
            });
            cardContent.appendChild(ips);
          }

          if (element.admin) {
            var admin = document.createElement('div');
            admin.style.paddingTop = '10px';
            admin.innerHTML = 'Account: ' + element.admin;
            cardContent.appendChild(admin);
          }

          var cardFooter = document.createElement('div');
          cardFooter.className = 'card-footer';
          cardFooter.innerHTML = '<span></span>';
          cardItem.appendChild(cardFooter);

          var restart = document.createElement('a');
          restart.className = 'button button-outline';
          restart.innerText = "Restart";
          cardFooter.appendChild(restart);
          
        });
      }
    });
    req.open("GET", 'vms');
    req.send();
  }
  
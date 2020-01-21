
var app = new Framework7({
    id: 'com.arc.machines',
    root: '#app',
    theme: "auto",
    name: 'Virtual Machines',
    routes: [
      {
        name: 'home',
        path: '/:name/admin',
        pageName: 'home'
      }
    ]
  });
  
var mainView = app.views.create('.view-main', {
  stackPages: true,
  on: {
    pageInit: function (data) {
      if (data.router.currentRoute.name === 'home') {
        var content = data.pageEl.querySelector(".page-content");
        loadMachines(content);
      }
    }
  }
});

function loadMachines(content) {
  var req = new XMLHttpRequest();
  req.addEventListener("load", () => {
    if (req.status === 200) {
      var machines = JSON.parse(req.responseText);
      content.innerHTML = '';
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
            list.appendChild(listItem);

            if (element.os === 'linux' || element.os === 'windows') {

              var linkItem = document.createElement('a');
              linkItem.innerText = ip;
              listItem.appendChild(linkItem);
  
              linkItem.onclick = () => {

                var content = '';

                if (element.os === 'linux') {
                  content = '<div class="popup"><div class="block"><p>Use an SSH client such as <a href="https://www.putty.org/">PuTTY</a> (for Windows) to connect to this machine:</p><br /><img src="../static/images/PuTTY.png" style="position: relative; left: 50%; margin-left: -150px;" ><br /><br /><ul>';
                  if (element.admin) content += '<li>Connection: <b>ssh ' + element.admin + '@' + ip + '</b></li>';
                  content += '<li>IP address: <b>' + ip + '</b></li><li>Port: <b>22</b></li>';
                  if (element.admin) content += '<li>User: <b>' + element.admin + '</b></li>';
                  content += '</ul></div></div>';
                }
                else {
                  content = '<div class="popup"><div class="block"><p>Use Remote Desktop app to connect to this machine:</p><br /><img src="../static/images/RDP.jpg" style="position: relative; left: 50%; margin-left: -210px;" ><br /><br /><ul>';
                  content += '<li>Computer: <b>' + ip + '</b></li><li>Port: <b>3389</b></li>';
                  if (element.admin) content += '<li>User name: <b>' + element.admin + '</b></li>';
                  content += '</ul></div></div>';
                }
  
                var popup = app.popup.create({ content: content });
                popup.open();
                
              };

            }
            else {
              listItem.innerText = ip;
            }

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

        var cardFooter = document.createElement('div');
        cardFooter.className = 'card-footer';
        cardFooter.innerHTML = '<span></span>';
        cardItem.appendChild(cardFooter);

        if (element.status === 'running') {
          var restart = document.createElement('a');
          restart.className = 'button button-outline';
          restart.innerText = "Restart";
          restart.onclick = () => {
            var post = new XMLHttpRequest(); //fire and forget
            post.open("POST", element.name + '/restart');
            post.send();
          };
          cardFooter.appendChild(restart);
        }
        
      });
    }
  });
  req.open("GET", 'vms');
  req.send();
}


var app = new Framework7({
  id: 'com.arc.creator',
  root: '#app',
  theme: "auto",
  name: 'Resource Creator',
  routes: [
    {
      name: 'home',
      path: '/',
      pageName: 'home'
    },
    {
      name: 'template',
      path: '/template/:path/:name',
      pageName: 'template',
    }
  ]
});

var mainView = app.views.create('.view-main', {
  stackPages: true,
  on: {
    pageInit: function (data) {
      switch (data.route.name) {
        case 'home':
          loadTemplates(data.pageEl.querySelector(".list > ul"));
          break;
        case 'template':
          data.pageEl.querySelector(".title").innerHTML = data.route.params.name;
          loadTemplate(data.route.params.path, data.route.params.name, data.pageEl.querySelector('page-content'));
          break;
      }
    }
  }
});

var router = mainView.router;

function loadTemplates(list) {
  var req = new XMLHttpRequest();
  req.addEventListener("load", () => {
    if (req.status === 200) {
      var templates = JSON.parse(req.responseText);
      templates.forEach(element => {
        var template = document.createElement('li');
        template.className = "arm-template";
        template.innerHTML = '<a href="#" class="item-link"><div class="item-content"><div class="item-media"><img style="height: 32px;" src="templates/' + element.path + '/' + element.image + '"></div><div class="item-inner">' + element.name + '</div></div></a>';
        list.appendChild(template);
        template.onclick = () => {
          router.navigate({ name: 'template', params: { name: element.name, path: element.path } });
        };
      });
    }
  });
  req.open("GET", 'templates');
  req.send();
}

function loadTemplate(path, name, content) {
  var req = new XMLHttpRequest();
  req.addEventListener("load", () => {
    if (req.status === 200) {
      var template = JSON.parse(req.responseText);
    }
  });
  req.open("GET", 'templates/' + path + '/template.json');
  req.send();
}
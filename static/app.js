
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
          loadTemplate(data.route.params.path, data.route.params.name, data.pageEl.querySelector('.page-content'));
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
        template.innerHTML = '<a href="#" class="item-link"><div class="item-content"><div class="item-media"><img style="height: 32px;" src="template/' + element.path + '/icon"></div><div class="item-inner">' + element.name + '</div></div></a>';
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
  
  var parameters = null;

  var req = new XMLHttpRequest();
  req.addEventListener("load", () => {
    if (req.status === 200) {
      parameters = JSON.parse(req.responseText);
      var list = content.querySelector("#template-parameters");
      for (var key in parameters) {

        var parameter = parameters[key];
        var keyFormat = key.replace(/_/g, " ");

        var parameterItem = document.createElement('li');
        parameterItem.className = 'item-content item-input';
        list.appendChild(parameterItem);

        var itemInner = document.createElement('div');
        itemInner.className = 'item-inner';
        parameterItem.appendChild(itemInner);

        var itemTitle = document.createElement('div');
        itemTitle.className = 'item-title item-label';
        itemTitle.innerText = keyFormat;
        itemInner.appendChild(itemTitle);

        var itemWrap = document.createElement('div');
        itemWrap.className = 'item-input-wrap';
        itemInner.appendChild(itemWrap);

        var itemInput = document.createElement('input');
        itemInput.type = 'text';
        itemInput.placeholder = parameter.metadata && parameter.metadata.description ? parameter.metadata.description : keyFormat;
        itemInput.value = parameter.defaultValue ? parameter.defaultValue : "";
        itemWrap.appendChild(itemInput);
        parameter._INPUT = itemInput;

        var itemClear = document.createElement('span');
        itemClear.className = 'input-clear-button';
        itemWrap.appendChild(itemClear);
        
      }
    }
  });
  req.open("GET", 'template/' + path + '/parameters');
  req.send();

  var btn = content.querySelector('#deploy');
  btn.onclick = () => {

    if (typeof parameters === 'undefined') return;

    var parameters = { };

    for (var key in parameters) {
      var parameter = parameters[key];
      if (parameter._INPUT) {
        parameters[key] = parameter._INPUT.value;
      }
    }

    var post = new XMLHttpRequest(); //fire and forget
    post.open("POST", 'template/' + path + '/deploy');
    post.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    post.send(JSON.stringify(parameters));
    router.back();

  };

}
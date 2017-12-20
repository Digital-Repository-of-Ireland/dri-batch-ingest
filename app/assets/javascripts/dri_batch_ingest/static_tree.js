function StaticTreeDataSource(data, foldersOnly) {
  var nodes = data;
  var nodeId = 0;
  var folderSelect = (foldersOnly === true);
  var rootNodesRendered = false;

  var delay = function() {
    var min = 10;  
    var max = 20;

    // random delay interval
    return Math.floor(Math.random() * (max - min + 1)) + min;
  };

  this.getData = function(options, callback) {

    var pathName = '';

    if (options.children) {
      nodes = options.children;
      if(options.dataAttributes.path) {
        pathName += options.dataAttributes.path;
        pathName += ' > '
      }
      pathName += options.name;

      if (folderSelect) {
        // remove any items, only show folders
        nodes = _.filter(nodes, function(node) {
          return node.type === 'folder';
        });
      }
    }
    else if(rootNodesRendered) {
      nodes = [];
    }
    else {
      pathName = 'All Items';
    }

    rootNodesRendered = true;

    _.each(nodes, function (node, index) {
      if (!node.dataAttributes) {
        node.dataAttributes = {};
      }
      if (!node.dataAttributes.id) {
        // ensure each node has an identifier
        node.dataAttributes.id = 'node' + (nodeId += 1);
      }
      if (!node.value) {
        // ensure each node has a value (sync with id if needed)
        node.value = node.dataAttributes.id;
      }

      node.dataAttributes.path = pathName;

      // determine whether the node has children
      // note: this will be used to hide the caret if necessary
      node.dataAttributes.hasChildren = (node.children && node.children.length > 0) ? true : false;
    });

    var dataSource = {
      data: nodes
    }

    // simulate delay
    window.setTimeout(function () {
      callback(dataSource);
    }, delay());
  }
 }
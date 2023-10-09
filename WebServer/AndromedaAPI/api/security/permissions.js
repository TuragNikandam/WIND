const defaultPermissions = {
  'GET': ["admin", "user"],
  'POST': ["admin"],
  'PUT': ["admin"],
  'DELETE': ["admin"],
};

const routeSpecificPermissions = {
  "/user": {
    'GET': ["admin", "user"],
    'POST': ["admin", "user"],
    'PUT': ["admin", "user"],
  },
  "/voting": {
    'GET': ["admin", "user", "guest"],
    'POST': ["admin", "user"],
    'PUT': ["admin"],
  },
  "/news": {
    'GET': ["admin", "user", "guest"],
  },
  "/news/:newsArticleId/comment": {
    'GET' : ["admin", "user", "guest"],
    'POST' : ["admin", "user"],
  },
  "/discussion": {
    'GET': ["admin", "user"],
  },
  "/discussion/:discussionId/post": {
    'GET' : ["admin", "user"],
    'POST' : ["admin", "user"],
  },
  "/topic": {
    'GET': ["admin", "user", "guest"],
  },
  "/party": {
    'GET': ["admin", "user", "guest"],
  },
  "/organization": {
    'GET': ["admin", "user", "guest"],
  },
};

// Function to find matching route pattern
const findMatchingRoute = (path) => {
  for (const route in routeSpecificPermissions) {
    if (new RegExp(`^${route.replace(/:[^\s/]+/g, "([\\w-]+)")}$`).test(path)) {
      return route;
    }
  }
  return null;
};

const permissionMiddleware = (req, res, next) => {
  const method = req.method;
  const role = req.user.role;
  const path = req.path;

  const matchingRoute = findMatchingRoute(path);

  // Check for route-specific permissions first
  if (matchingRoute) {
    const routePermissions = routeSpecificPermissions[matchingRoute];
    if (
      routePermissions &&
      routePermissions[method] &&
      routePermissions[method].includes(role)
    ) {
      return next();
    }
  }

  // Fall back to default permissions
  if (defaultPermissions[method] && defaultPermissions[method].includes(role)) {
    return next();
  }

  // If no permissions match, deny access
  res.status(403).send("Forbidden: Insufficient permissions");
};

module.exports = permissionMiddleware;

'use strict';

/**
 * `is-admin` policy
 * Checks if the authenticated user has admin role
 */

module.exports = (policyContext, config, { strapi }) => {
  const { user } = policyContext.state;

  if (!user) {
    return false;
  }

  // Check if user has admin role
  const isAdmin = user.role && (user.role.type === 'admin' || user.role.name === 'Admin');

  if (!isAdmin) {
    return false;
  }

  return true;
};

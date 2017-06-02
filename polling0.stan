// polling model - local level
data {
  int<lower = 1> N;
  int<lower = 1> T;
  // poll results
  vector[N] y;
  // poll standard errors
  vector<lower = 0.>[N] s;
  int<lower = 1, upper = T> time[N];
  // distribution of initial latent state
  real theta_loc;
  real<lower = 0.> theta_scale;
}
parameters {
  // latent value
  vector[T] theta;
}
transformed parameters {
  // expected value for each poll
  vector[N] mu;
  for (i in 1:N) {
    mu[i] = theta[time[i]];
  }
}
model {
  theta ~ normal(theta_loc, theta_scale);
  y ~ normal(mu, s);
}
generated quantities {
  vector[N] log_lik;
  for (i in 1:N) {
    log_lik[i] = normal_lpdf(y[i] | mu[i], s[i]);
  }
}

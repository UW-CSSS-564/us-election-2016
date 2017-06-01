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
  real theta_init_loc;
  real<lower = 0.> theta_init_scale;
  // priors ----
  // latent innovations
  real<lower = 0.> tau_scale;
}
transformed data {
}
parameters {
  // latent state innovations
  vector[T] omega_raw;
  // latent state innovations scale
  real<lower = 0.> tau;
}
transformed parameters {
  // poll expected value
  vector[N] mu;
  // latent scales
  vector[T] theta;
  // polling mean
  theta[1] = theta_init_loc + omega_raw[1] * theta_init_scale;
  for (t in 2:T) {
    theta[t] = theta[t - 1] + omega_raw[t] * tau;
  }
  for (i in 1:N) {
    mu[i] = theta[time[i]];
  }
}
model {
  tau ~ cauchy(0., tau_scale);
  omega_raw ~ normal(0., 1.);
  y ~ normal(mu, s);
}
generated quantities {
  vector[N] log_lik;
  for (i in 1:N) {
    log_lik[i] = normal_lpdf(y[i] | mu[i], s[i]);
  }
}

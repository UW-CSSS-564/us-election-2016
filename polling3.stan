// polling model
// local level with unknown innovation variance and
// polling house effects.
data {
  // number of polls
  int<lower = 1> N;
  // time periods (days)
  int<lower = 1> T;
  // poll results
  vector[N] y;
  // poll standard errors
  vector<lower = 0.>[N] s;
  int<lower = 1, upper = T> time[N];
  // polling houses
  int<lower = 1> H;
  int<lower = 1, upper = H> house[N];
  // distribution of initial latent state
  real theta_init_loc;
  real<lower = 0.> theta_init_scale;
  // priors ----
  // latent innovations
  real<lower = 0.> tau_scale;
  // house effects
  real<lower = 0.> zeta_scale;
}
transformed data {
}
parameters {
  // latent state innovations
  vector[T] omega_raw;
  // latent state innovation scale
  real<lower = 0.> tau;
  // house effects
  vector[H] eta_raw;
  // house effects hyperprior scale
  real<lower = 0.> zeta;
}
transformed parameters {
  // poll expected value
  vector[N] mu;
  // latent scales
  vector[T] theta;
  // house effects
  // if these aren't set so that the mean is exactly 0, I found it was
  // hard to identify theta.
  vector[H] eta;
  eta = ((eta_raw - mean(eta_raw)) / sd(eta_raw)) * zeta;
  // polling mean
  theta[1] = theta_init_loc + omega_raw[1] * theta_init_scale;
  for (t in 2:T) {
    theta[t] = theta[t - 1] + omega_raw[t] * tau;
  }
  for (i in 1:N) {
    mu[i] = theta[time[i]] + eta[house[i]];
  }
}
model {
  zeta ~ cauchy(0., zeta_scale);
  eta_raw ~ normal(0., 1.);
  tau ~ cauchy(0., tau_scale);
  omega_raw ~ normal(0., 1.);
  y ~ normal(theta, s);
}
generated quantities {
  vector[N] log_lik;
  for (i in 1:N) {
    log_lik[i] = normal_lpdf(y[i] | theta[i], s[i]);
  }
}

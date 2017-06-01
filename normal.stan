data {
  int N;
  vector[N] y;
  vector<lower = 0.>[N] s;
  // priors
  real<lower = 0.> theta_loc;
  real<lower = 0.> theta_scale;
}
parameters {
  real theta;
}
model {
  theta ~ normal(theta_loc, theta_scale);
  y ~ normal(theta, s);
}

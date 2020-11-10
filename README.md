
<!-- README.md is generated from README.Rmd. Please edit that file -->

VarRedOpt
=========

<!-- badges: start -->
<!-- badges: end -->

-   [Installation](#installation)
-   [Example](#example)
-   [Details and Algorithms](#details-and-algorithms)
-   [simulate outer](#simulate-outer)
-   [Antithetic Variates](#antithetic-variates)
-   [Inner Control Variates](#inner-control-variates)
-   [Outer Control Variates](#outer-control-variates)
-   [Importance Sampling](#importance-sampling)
-   [Adding Custom Function to
    VarRedOpt](#adding-custom-function-to-varredopt)
-   [License](#license)

The increase in computing power has made us capable to run bigger
simulations. We can choose bigger sample sizes with bigger dimensions.
Nevertheless, this phenomenon does not make the need for an efficient
simulation disappear. We still have to choose the most efficient way to
make our simulations in order to get the most robust results with the
computing power at the hand.

The reliability of the simulation lies in the variance of the
simulation. As the simulation size increase, variance is expected to be
decreased. We can increase simulation size to the point but after a
certain point the simulation time will be infeasible to get results.
This problem reveals the need for a different approach. We need a set of
tools to get more robust simulation results with the same simulation
size. This is where variance reduction (VR) algorithms come to our help.

A Variance Reduction Algorithm is an algorithm that behaves like the
simulation itself. These algorithms uses simulations as an input and
returns another simulation with approximately the same expected value
and less variance value.

In this library, we are sharing different VR algorithms as a framework.
Antithetic Variates, Inner Control Variates, Outer Control Variates and
Importance Sampling algorithms are applied and presented as ready-to-use
manner. Any user can run their simulations with different combinations
of these methods and get advantage of these variance reduction
algorithms.

Simulation is needed to approximate the most probable behavior of the
system or the solution of the problem at the hand. In order to do that,
we use different simulation techniques. These techniques can take random
variables as input and attempt to approximate the solution of the our
problem.

Our variance reduction framework makes it easier to conduct experiments
without writing variance reduction algorithms. The idea is to get
desired variance reduction algorithms from the user via a function that
launches the simulation process and prints the simulation results. The
launcher function is the only function user needs to fill with
parameters. The parameters of this function are the name of the variance
reduction algorithms to be applied, the naive simulation and parameters
to be passed on the simulation function. The name of this launcher
function in our framework is *sim.outer(. . . ).* Variance reduction
algorithms are already implemented in our framework and the user can
easily take advantage of these methods by simply writing their function
names.

Installation
------------

You can install the released version of VarRedOpt from
[CRAN](https://CRAN.R-project.org) with:

    install.packages("VarRedOpt")

And the development version from [GitHub](https://github.com/) with:

    # install.packages("devtools")
    devtools::install_github("onurboyar/VarRedOpt")

Example
-------

To make things more concrete, let’s specify the parameters needed to
simulate an Asian Call Option. To simulate an Asian Call Option, we need
to have

-   Strike price (K)
-   Interest rate (riskfree rate) (r)
-   Starting price (S0)
-   Sigma, yearly volatility (sigma)
-   Time (ti)

To launch a simulation process via sim.outer function, we need to give
the simulation size (n) and the dimension values (d).

In order to get naive simulation without applying any of the variance
reduction algorithms, we need just need to give the above parameters to
sim.outer function in the following way.

    devtools::install_github("onurboyar/VarRedOpt")
    #>      checking for file ‘/private/var/folders/x0/92n0x33d1q33x2l2th2d_2yr0000gn/T/RtmpuTmCH8/remotes8d5937a4381e/onurboyar-VarRedOpt-d9b29a0/DESCRIPTION’ ...  ✓  checking for file ‘/private/var/folders/x0/92n0x33d1q33x2l2th2d_2yr0000gn/T/RtmpuTmCH8/remotes8d5937a4381e/onurboyar-VarRedOpt-d9b29a0/DESCRIPTION’
    #>   ─  preparing ‘VarRedOpt’:
    #>      checking DESCRIPTION meta-information ...  ✓  checking DESCRIPTION meta-information
    #>   ─  checking for LF line-endings in source and make files and shell scripts
    #>   ─  checking for empty or unneeded directories
    #>   ─  building ‘VarRedOpt_0.1.0.tar.gz’
    #>      
    #> 
    library(VarRedOpt)
    sim.outer(n=1e5, d=3, q.outer = myq_asian,
                   K = 100, ti=(1:3)/12, r = 0.03, sigma = 0.3, S0 = 100)
    #>    Estimation StandardError 
    #>    4.54300000    0.04283238

sim.outer function creates a matrix with 10<sup>5</sup> rows and 3
columns. Values in that matrix are drawn from standard normal
distribution. This matrix is sent to *myq\_asian* function as an input
and Asian Call Option prices are simulated. The simulated values are
sent back to *sim.outer* function to calculate estimation and standard
error values. User sees these values as the output of the simulation.

There are a lot of different parameters to be used in different
functions in our framework. In order to handle different parameters and
to create a flexible framework, we are taking advantage of *ellipsis*
parameter (. . . ) of R inside our functions.

Details and Algorithms
----------------------

The main function of our framework is sim.outer() function. It simulates
the input variables, which are standard normal random variables. The
size of this simulated in determined by the given parameters, n and
d. Given these values, sim.outer() creates Z matrix which includes
standard normal random variables. The Z matrix is the input of our
target simulation. If we stick to our previous example, Z matrix will be
passed to myq\_asian() function within sim.outer() function. Asian
Option function will simulate Asian Option prices using Z matrix and
return calculated prices to our main function. The main function
calculates expected value and variance of the returning values and
prints them as final output.

simulate outer
--------------

If we set simulation size to 10<sup>7</sup> we already have big
simulation size and it is hard to run this simulation few times to check
if we are getting consistent results. We can compare expected values
obtained from these simulations with confidence interval and see if
expected values are within the confidence interval. It is hard to
perform this task if our simulation size is equal to 10<sup>6</sup> or
10<sup>7</sup> but it is not hard if it is equal to 10<sup>3</sup>.
Besides, another problem is that all functions need to store several
vectors of length n, this grows bigger if we have a dimension greater
than 1, and it makes simulation hard to run due to memory constraints.
We can run simulations of size 10<sup>3</sup> few times, let’s say
10<sup>3</sup> after running our main simulation with simulation size
10<sup>6</sup>. After estimated mean of our bigger simulation we can
check if it lays within confidence intervals of these 10<sup>3</sup>
simulations and come up with different measure to evaluate our
simulation. In our framework it is very simple to make such analysis.
All needed to be done is to set auto.repetition parameter to a value
rather than 1 in the following way.

    sim.outer(n=1e5, d=3, auto_repetition = 100, q.outer = myq_asian, 
                   K = 100, ti = (1:3)/12, r = 0.03, sigma = 0.3, S0 = 100)

Above function will run simulation with n = 1000 auto\_repetition times,
which is 100. Another aspect need to be mentioned of the sim.outer()
function is the q.outer parameter. In the above example it is set to
function that simulates Asian Option. In order to perform variance
reduction via the algorithms within our framework, we need to give
different parameter(s) to our main function. If we are to add Antithetic
Variates within our framework, q.outer parameter will be set to sim.AV
and the new parameter will appear. It is the parameter that we need
inside sim.AV function to call in order to perform variance reduction.
When we set q.outer to sim.AV, we need to specify another parameter to
tell our framework the function to be simulated, like Asian Option.
Since we are using sim.AV function in this example, it must be called
inside of the sim.AV function.

Antithetic Variates
-------------------

In order to add antithetic variates to our framework and simulate asian
options we need to slightly change the sim.outer function given above.
Antithetic Variates calls the simulation function twice by using
opposite signed inputs. The q.outer parameter of our main function will
be *sim.AV*. In order to specify the function to be simulated we need
another parameter. This parameter is named as *q.av*. It’s name includes
av because this parameter is only needed when we are using sim.AV within
our framework. We will give *q.av = myq\_asian* this time. The function
now becomes

    sim.outer(n=1e5, d=3, q.outer = sim.AV, 
                   q.av = myq_asian, K = 100, ti = (1:3)/12, r = 0.03, sigma = 0.3, S0 = 100)
    #>    Estimation StandardError 
    #>    4.55000000    0.02285073

Inner Control Variates
----------------------

Like antithetic variates, inner control variates algorithm does not
require any additional parameters. It can be directly applied to naive
simulation since it uses only input variables as control variates. To
run our simulation with inner control variates, we need to assign
different function to *q.outer* parameter. Our framework has a built-in
function named *sim.InnerCV()*. In order to simulate Asian Option with
Inner Control Variates, the following function can be used.

    sim.outer(n=1e5, d=3, q.outer = sim.InnerCV, 
                   q.cv = myq_asian,K = 100, ti =(1:3)/12, r = 0.03, sigma = 0.3, S0 = 100)
    #>    Estimation StandardError 
    #>    4.53800000    0.01698056

Note that we are using *q.cv* parameter this time.

Outer Control Variates
----------------------

Outer Control Variates approach is using the result of a similar problem
to the task at hand in which the exact solution is known. Deciding good
outer control variate results in a great amount of variance reduction.
The main disadvantage of this method is that it is difficult and
requires domain knowledge to come up with such a control variate; also
the additional computations may be quite slow depending on the control
variate.

In Option Pricing, we can use prices of other options as Outer Control
Variates. Since we use expected values of the control variates in our
calculations, the exact solution of the future prices must be known.

As an example we can take Asian Options again. If we want to simulate
Asian Option prices using Outer Control variates we can use Asian Call
Option with Geometric Mean as an Outer Control Variate since it’s exact
solution is known.

    sim.outer(n=1e5, d=3, q.outer = sim.AV, q.av = sim.GeometricAvg, 
                   q.ga = myq_asian,K = 100, ti = (1:3)/12, r = 0.03, sigma=0.3, S0=100)
    #>    Estimation StandardError 
    #>  4.5400000000  0.0006227557

Outer Control Variates function is the same as Inner Control Variates
function in several ways. It has the same control for returning list
lengths and application logic of the IS weight is the same. The major
difference is the control variate itself. In Inner Control Variates
function, we use input columns as control variates. In Geometric Average
Outer Control Variate, we use product of the prices as control variates
and it is returned from our myq\_asian function. The expectation of this
control variate is calculated by BS\_Asian\_geom function.

Using IS and CV together is not as straightforward as using AV and CV or
AV and IS together. Applying IS weight and returning updated simulation
values to CV does not work well. Following the opposite approach,
applying CV and returning updated values to IS and applying IS weight to
these values does not work well either. What we do is that applying
multiplying target values with IS weight after decreasing variance by
applying Control Variates.

Importance Sampling
-------------------

Importance Sampling is a variance reduction technique that is especially
useful in rare event simulation. In an Option Pricing problem like Asian
Call Options, when we have strike price like 140 we have a rare event
simulation problem.

To be able to sample from tails, we sample from the different
distribution and fix the error of not sampling from the correct
distribution in Importance Sampling.

In our framework, in order to apply Importance Sampling, user should
specify two parameters. One is muis and the other is sis. muis is the
mean value of the importance density and sis is the standard deviation
of the importance density.

If user do not want to specify muis value, use\_pilot\_study parameter
can be used to look for an optimum muis value by using a pilot study. In
current version, muis values in an interval \[1.01, 1.2\] is used as
candidate values for muis values. Starting from 1.01, values are
incremented by 0.01 until it is reached to 1.2. sis, standard deviation
of the IS density, is not recommended to be changed. We do not offer
optimization for sis value. Nevertheless, our framework look for optimum
muis value by conducting a pilot study inside the function.

    sim.outer(1e6,d=3,q.outer=myq_asian,K=120,
                   ti=(1:3)/12,r=0.03,sigma=0.3,S0=100)
    #>    Estimation StandardError 
    #>   0.255000000   0.003160006

Now, let’s add Inner Control Variates and obtain a little variance
reduction.

    sim.outer(n=1e6,d=3,q.outer=sim.InnerCV,
                   q.cv=myq_asian,K=120,ti=(1:3)/12,r=0.03,sigma=0.3,S0=100)
    #>    Estimation StandardError 
    #>    0.25500000    0.00261813

Because we set strike price to 120, simulated results are rare. We
expect IS to reduce variance. Let’s use IS and Inner CV together. We
apply IS weights after calculating simulated values in Control Variates
function.

    sim.outer(n=1e6,d=3,q.outer=sim.InnerCV,q.cv=sim.IS,muis=1.03,sis=1,
                   q.is=myq_asian,K=120,ti=(1:3)/12,r=0.03,sigma=0.3,S0=100)
    #>    Estimation StandardError 
    #>   0.256000000   0.000614824

Adding Custom Function to VarRedOpt
-----------------------------------

In this section motivating examples will be given to show how to perform
naive simulation using our framework. If we want to simulate Euclidean
distance of iid N(0, 1) vector to given point, we can write following
function.

    myq_euclidean <- function(zm,point=c(1,2,1)){
      # returns Euclidean distance of iid N(0,1) vector to "point"
      d <- length(point)
      sumDist2 <- 0
      for(i in 1:d) sumDist2 <- sumDist2 + (point[i]-zm[,i])^2
      
      returning_list = list(sqrt(sqrt(sumDist2)))
      return(returning_list)
    }

This function, *myq\_euclidean*, takes two parameters. The length of the
point vector and the dimension of the z.matrix should be the same in
order to find euclidean distance between these points. Note that
returning value type have to be list.

Now, let’s simulate myq using our framework.

    sim.outer(n=1e6,d=2,q.outer=myq_euclidean,point=c(1,3))
    #>    Estimation StandardError 
    #>  1.8020000000  0.0005443944

Let’s see the output when we use auto repetition.

    sim.outer(n=1e6,d=2,auto_repetition=1000,q.outer=myq_euclidean,point=c(1,3))
    #>              Estimation           StandardError ConfidenceIntervalRatio 
    #>            1.8020000000            0.0005443944            0.9470000000

*We observe that estimated value is in the confidence interval 947 times
out of 1000.*

LICENSE
-------

MIT © [Wolfgang Hörmann, Onur Boyar](https://github.com/onurboyar)

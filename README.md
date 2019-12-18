
Reservoir Operation Optimization using the Charged System Search (CSS) Metaheuristic Optimization algorithm

Main publication: https://www.mdpi.com/2306-5338/6/1/5

Optimization of water-supply and hydropower reservoir operation


The CSS algorithm is a metaheuristic optimization method inspired by the governing laws of electrostatics in physics and motion from the Newtonian mechanics.
The CSS algorithm is then used to optimally solve the water-supply and hydropower operation of “Dez” reservoir in southern Iran over three different operation periods of 60, 240, and 480 months.

Charged System Search (CSS) Algorithm
The CSS algorithm is developed based on the governing laws of electrostatics in physics and motion from the Newtonian mechanics [41]. The CSS utilizes a number of agents or solution candidates, which are called charged particles (CPs). Each CP is considered to be a charged sphere which can impose electrical forces on the other CPs according to the Coulomb and Gauss laws of electrostatics. Then, the Newton’s law is utilized to calculate the acceleration value based on the resultant force acting on each CP. Finally, utilizing the Newtonian mechanics, the position of each CP is determined at any time step based on its previous position, velocity and acceleration in the search space [41]. Each CP is considered as a charged sphere with radius a, which has a uniform volume charge density (qi) equal to:
qi=fit(i)−fitworstfitbest−fitworst, i=1,2,…,N
(1)where fitbest and fitworst are the best and the worst fitness values of all the particles, and fit(i) is the fitness of the particle i, and N is the total number of CPs. The initial positions of CPs are assigned randomly in the search space, within the boundaries determined by the problem. The initial velocities of the CPs are taken as zero.
The CPs are scattered in the search space and can impose electric forces on the others. The magnitude of the force for the CP located inside or outside of the sphere are determined differently. The resultant electrical force acting on CPs inside or outside of the sphere is determined using:
Fj=qj∑i,i≠j(qia3rij⋅i1+qirij2⋅i2)pij(Xi−Xj)  ⟨j=1,2,…,Ni1=1,i2=0⇔rij<ai1=0,i2=1⇔rij≥a
(2)where Fj is the resultant force acting on the jth CP. rij is the separation distance between two particles defined as:
rij=∥Xi−Xj∥∥(Xi+Xj)/2−Xbest∥+ε
(3)where Xi and Xj are the positions of the ith and jth CPs, respectively; Xbest is the position of the best current CP. ε here is a small positive number to avoid singularity. The pij determines the probability of moving each CP toward the others as:
pij={1  fit(i)−fitbestfit(j)−fit(i)>rand or fit(j)>fit(i)0  otherwise
(4)
As shown in Equation (2), the force imposed on a CP inside the sphere is proportional to the separation distance between particles. However, for the CPs located outside the sphere, it is inversely proportional to the square of the separation distance. The new locations of the CPs are calculated based on the resultant forces and the laws of the motion. At this step, each CP moves towards its new position according to the resultant forces and its previous velocity as:
Xj,new=randj1⋅ka⋅Fjmj⋅Δt2+randj2⋅kv⋅Vj,old⋅Δt+Xj,old
(5)
Vj,new=Xj,new−Xj,oldΔt
(6)where randj1 and randj2 are two random numbers uniformly distributed in the range (0,1). Here, mj is the mass of the j th CP, which is set to be equal to qj. Δt is the time step and is set to unity. ka is the acceleration coefficient; kv is the velocity coefficient that controls the influence of the previous velocity, which may either be kept constant or let it vary in the next time steps:
ka=α×(1+iter/itermax),  kv=β×(1−iter/itermax)
(7)where iter is the current iteration number and itermax is the maximum number of iterations set for the algorithm run. According to this equation, kv decreases linearly to zero while ka increases to 2α as the number of iterations increases, which preserves the balance between the exploration and the speed of convergence [41]. It is noteworthy that the parameters α and β in Equation (7) are tunable and defining these parameters result in definition of the acceleration and velocity coefficients (ka and kv). Value of 0.5 for both parameters α and β has been recommended in the reference paper of the CSS algorithm [41]. Substituting for ka and kv from Equation (7), Equations (5) and (6) can be rewritten as:
Xj,new=α×randj1⋅(1+iter/itermax)⋅∑i,i≠j(qia3rij⋅i1+qirij2⋅i2)pij(Xi−Xj)+β×randj2⋅(1−iter/itermax)⋅Vj,old+Xj,old
(8)
Vj,new=Xj,new−Xj,old
(9)
In addition, to save the best results, a memory, known as the Charged Memory (CM), is recommended [41]. If each CP moves out of the search space, its position is corrected using the harmony search-based handling approach, in which a new value is produced or selected from the CM, on a probabilistic basis. It is highly recommended to refer to the main reference [41] for better understanding the concepts and structure of the CSS algorithm, as some concepts in the present paper might not be described as detailed.
In the original CSS algorithm, when the calculations of the amount of forces are completed for all CPs, the new locations of the CPs are determined and also CM updating is fulfilled. In other words, the new location for each CP is determined after completion of an iteration and before commencement of the new iteration. Kaveh and Talatahari [45], ignoring this assumption, proposed the Enhanced CSS algorithm in which after evaluation of each CP, all updating processes are performed. Using this method of updating in the CSS algorithm, the new position of each agent can affect the moving process of the subsequent CPs while in the standard CSS, unless an iteration is completed, the new positions are not utilized. This enhanced algorithm, compared to the original CSS, while not requiring additional computational time, improves the performance of the algorithm by using the information obtained by CPs instantly. In a detailed investigation, considering the i th CP in the original CSS, although the solutions obtained by the CPs with a number less than i are created before the selected agent is used, however, these new designs cannot be employed to direct the i th CP in the current iteration. On the other hand, the original CSS archives the information obtained by the agents until a pre-determined time and this results in a break in the optimization process, while in the enhanced CSS algorithm the information of the new position of each agent is utilized in the subsequent search process, and this procedure improves the optimization abilities of the algorithm and also increases the convergence speed [45].

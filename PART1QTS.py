import numpy as np
import matplotlib.pyplot as plt
from scipy.linalg import sqrtm  

def simulate_wavefunction_by_counts(N_pulses, simulate_psi2=True):
    N_HH = 0
    N_HV = 0
    N_VH = 0
    N_VV = 0
    
    # --- Physical Simulation Parameters ---
    noise_level = 0.01  # Gaussian noise simulating laser fluctuations and dark current
    threshold = 0.6     # Digitization threshold for discrete "clicks"
    
    for _ in range(N_pulses):
        # Classical pseudo-random polarization basis selection
        theta_in_deg = 0.0 if np.random.rand() < 0.5 else 90.0
        theta_alice = np.radians(theta_in_deg)
        
        # Emulating entanglement correlation by shifting Bob's measurement angle
        theta_bob = np.radians(theta_in_deg + 90.0 if simulate_psi2 else theta_in_deg)
        
        # 1. Calculate Ideal Analog Intensities (Malus's Law) and Add Noise
        I_A_H = np.cos(theta_alice)**2 + np.random.normal(0, noise_level)
        I_A_V = np.sin(theta_alice)**2 + np.random.normal(0, noise_level)
        
        I_B_H = np.cos(theta_bob)**2 + np.random.normal(0, noise_level)
        I_B_V = np.sin(theta_bob)**2 + np.random.normal(0, noise_level)
        
        # 2. Digitization (Post-selection)
        # Register a click only if the intensity crosses the predefined threshold
        click_A_H = I_A_H >= threshold
        click_A_V = I_A_V >= threshold
        click_B_H = I_B_H >= threshold
        click_B_V = I_B_V >= threshold
        
        # 3. Coincidence Counting
        # Register an event only if both Alice and Bob cross the threshold simultaneously
        if click_A_H and click_B_H: N_HH += 1
        if click_A_H and click_B_V: N_HV += 1
        if click_A_V and click_B_H: N_VH += 1
        if click_A_V and click_B_V: N_VV += 1
            
    # --- Tomographic Reconstruction and Density Matrix ---
    N_total = N_HH + N_HV + N_VH + N_VV
    
    if N_total > 0:
        # Normalize discrete counts matching the experimental MATLAB QST analysis
        amplitudes = np.sqrt(np.array([[N_HH], 
                                       [N_HV], 
                                       [N_VH], 
                                       [N_VV]], dtype=float) / N_total)
    else:
        amplitudes = np.zeros((4, 1))
        
    # Calculate density matrix (rho) via outer product of the amplitude vector
    rho_final = np.dot(amplitudes, amplitudes.T)
    
    return rho_final


def plot_fidelity_convergence():
    # Setup visualization parameters
    plt.rcParams.update({
        'font.family': 'serif',
        'font.serif': ['Times New Roman', 'DejaVu Serif'],
        'font.size': 12,
        'axes.labelsize': 14,
        'axes.titlesize': 14,
        'xtick.direction': 'in',
        'ytick.direction': 'in',
        'xtick.top': True,
        'ytick.right': True,
    })

    N_values = np.arange(2, 101, 1)
    fidelities = []
    
    # Define the ideal density matrix for the |Psi+> Bell state
    rho_ideal = np.zeros((4, 4))
    rho_ideal[1, 1] = 0.5  # |HV><HV|
    rho_ideal[2, 2] = 0.5  # |VH><VH|
    rho_ideal[1, 2] = 0.5  # |HV><VH|
    rho_ideal[2, 1] = 0.5  # |VH><HV|
    
    # 4. Fidelity Calculation Loop
    for N in N_values:
        rho_exp = simulate_wavefunction_by_counts(N, simulate_psi2=True)
        
        # Calculate Uhlmann's Fidelity between simulated and ideal states
        sqrt_rho = sqrtm(rho_ideal)
        inner_matrix = np.dot(sqrt_rho, np.dot(rho_exp, sqrt_rho))
        trace_val = np.trace(sqrtm(inner_matrix))
        F = (trace_val.real) ** 2
        fidelities.append(F)
        
        # Print numerical output for specific points of experimental interest
        if N in [10, 20, 50]:
            print(f"\n--- Reconstructed Density Matrix at N = {N} ---")
            for row in rho_exp:
                print("  ".join([f"{val:6.3f}" for val in row]))
            print("-" * 44)
            print(f"Fidelity: {F:.4f}\n")

    # --- 5. Visualization ---
    plt.figure(figsize=(8, 5))
    
    plt.scatter(N_values, fidelities, color='#003366', alpha=0.6, s=15, label='State Fidelity parameter')
    
    # Mark points corresponding to physical lab experiment pulse sequences
    plt.axvline(10, color='#CC0000', linestyle='--', linewidth=1.5, label='Experimental Setup ($N=10$)')
    plt.axvline(20, color="#A90101", linestyle='--', linewidth=1.5, label='Experimental Setup ($N=20$)')
    plt.axvline(50, color="#710202", linestyle='--', linewidth=1.5, label='Experimental Setup ($N=50$)')

    plt.axhline(1.0, color='gray', linestyle=':', linewidth=1.5)
    
    plt.xlabel('Number of Pulses ($N$)')
    plt.ylabel('State Fidelity factor ($F$)')
    
    plt.ylim(0.8, 1.01)
    plt.xlim(0, 100)
    
    plt.legend(loc='lower right', frameon=True)
    plt.tight_layout()
    plt.savefig('Fidelity_Convergence.pdf', format='pdf', bbox_inches='tight')
    plt.show()

if __name__ == "__main__":
    plot_fidelity_convergence()
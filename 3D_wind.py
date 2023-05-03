import numpy as np
import xarray as xr
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

dataset = xr.open_dataset('vx3_3d_348.nc')    #radial wind

def plot_3d_radial_wind(radial_wind, output_file='3D_radial_wind_field.png'):
    fig = plt.figure()
    fig.set_size_inches(8, 8)  # Adjust the figure size, for example 12 inches width and 12 inches height
    ax = fig.gca(projection='3d')

    z_levels = np.arange(0, radial_wind.shape[0], 30) * 30  # every 10th level, multiplied by 30 for height in meters
    x_all, y_all = np.meshgrid(np.linspace(-600, 600, radial_wind.shape[2]), np.linspace(-600, 600, radial_wind.shape[1]))
    x_grid = x_all[0:1201, 0:1201]
    y_grid = y_all[0:1201, 0:1201]

    cmap = plt.get_cmap('jet_r')
    levels = np.linspace(-25, 10, 36)
    norm = plt.Normalize(levels.min(), levels.max())

    for z in z_levels:
        colors = cmap(norm(radial_wind[z // 30]))
        ax.plot_surface(x_grid, y_grid, z * np.ones_like(x_grid), facecolors=colors, rstride=1, cstride=1, linewidth=0, antialiased=False, shade=True)

    ax.set_xlabel('X')
    ax.set_ylabel('Y')
    ax.set_zlabel('Height (m)')  # updated z-label
    ax.set_title('3D Radial Wind Field')

    # Rotate the plot
    ax.view_init(elev=25, azim=15)  # 30 degrees elevation and 45 degrees azimuth

    # Add colorbar
    sm = plt.cm.ScalarMappable(cmap=cmap, norm=norm)
    sm.set_array([])
    cbar = plt.colorbar(sm, orientation='horizontal', pad=0.05, shrink=0.7)  # horizontal colorbar with reduced size (shrink parameter)
    cbar.set_label('Radial Wind Speed (m/s)')

    plt.savefig(output_file, dpi=300)
    plt.close(fig)

plot_3d_radial_wind(radial_wind, output_file='3D_radial_wind_field.png')

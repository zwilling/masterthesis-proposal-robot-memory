# generate database for evaluation
# generated a database about object in a home environment

from pymongo import *
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages
from matplotlib.legend_handler import HandlerLine2D
import numpy as np

# config variables:

client = MongoClient('localhost:27017')
col = client.eval.durations

def add_docs():
    for i in range(OBJECTS):
        storage = random.randint(0,PLACES)
        if USE_DISTRIBUTION and random.random() < CORRALATION:
            place = storage
        else:
            place = random.randint(0,PLACES)
        col.insert({"name" : i, "place" : place, "storage" : storage})

def plot_inserts():
    # get data
    sizes = []
    durations = []
    for p in col.find({"op":"insert","obj.db-size":{"$exists":True}}):
        sizes.append(p["obj"]["db-size"])
        durations.append(p["total"] * 1000.0)

    with PdfPages('insert-durations.pdf') as pdf:
        # format plot
        plt.figure(figsize=(8,5))
        plt.xlabel('db size (#docs)')
        plt.ylabel('duration (ms)')
        plt.axis([0, 100000, 0.0, 0.5])
        
        # fill plot
        plt.plot(sizes, durations, 'bo')

        # save plot
        pdf.savefig()
        plt.close()
        # plt.show()
        
def plot_query():
    # get data
    sizes = []
    durations_not_found = []
    durations_found = []
    durations_comparison = []
    durations_comparison_all = []
    for p in col.find({"op":"query","query.$comment.exp":"not-found"}):
        sizes.append(p["query"]["$comment"]["db-size"])
        durations_not_found.append(p["total"] * 1000.0)
    for p in col.find({"op":"query","query.$comment.exp":"found"}):
        durations_found.append(p["total"] * 1000.0)
    for p in col.find({"op":"query","query.$comment.exp":"compare"}):
        durations_comparison.append(p["total"] * 1000.0)
    for p in col.find({"op":"query","query.$comment.exp":"compare-all"}):
        durations_comparison_all.append(p["total"] * 1000.0)

    with PdfPages('query-durations.pdf') as pdf:
        # format plot
        plt.figure(figsize=(8,5))
        plt.xlabel('db size (#docs)')
        plt.ylabel('duration (ms)')
        plt.axis([0, 100000, 0.0, 300])
    
        # fill plot
        # plt.plot(sizes, durations_not_found, 'o', label='not found')
        plt.plot(sizes, durations_found, 'o', label='find obj by name')
        plt.plot(sizes, durations_comparison, '*', label='obj.storage != obj.place')
        # plt.plot(sizes, durations_comparison_all, 'o', label='comare all')
        plt.legend(loc=5)
        
        # save plot
        plt.show()
        # pdf.savefig()
        # plt.close()
        
def plot_update():
    # get data
    sizes = []
    durations = []
    for p in col.find({"op":"remove","query.$comment.exp":"remove"}):
        sizes.append(p["query"]["$comment"]["db-size"])
        durations.append(p["total"] * 1000.0)
        
    with PdfPages('update-durations.pdf') as pdf:
        # format plot
        plt.figure(figsize=(8,5))
        plt.xlabel('db size (#docs)')
        plt.ylabel('duration (ms)')
        plt.axis([0, 100000, 0.0, 50])
    
        # fill plot
        plt.plot(sizes, durations, 'o', label='update')
        # plt.legend(loc=5)
        
        # save plot
        plt.show()
        # pdf.savefig()
        # plt.close()

        
def plot_computable():
    # get data
    sizes = []
    durations_compute = []
    durations_overhead = []
    for p in client.eval.computables.find({"query.$comment.exp":"computable"}).sort("query.$comment.db-size",1):
        compute = p["computables"][1]["compute"]
        sizes.append(p["query"]["$comment"]["db-size"])
        durations_compute.append(compute * 1000.0)
        durations_overhead.append((p["total"]-compute) * 1000.0)
        
    durations_stack = np.row_stack((durations_overhead, durations_compute))
    
    with PdfPages('computable-durations.pdf') as pdf:
        # format plot
        #fig, ax = plt.subplots()

        plt.figure(figsize=(8,5))
        plt.xlabel('db size (#docs)')
        plt.ylabel('duration (ms)')
        plt.axis([0, 100000, 0.0, 80])
    
        # fill plot
        polys = plt.stackplot(sizes, durations_stack)
        
        #construct legend:
        legendProxies = []
        for poly in polys:
            legendProxies.append(plt.Rectangle((0, 0), 1, 1, fc=poly.get_facecolor()[0]))
        plt.legend(legendProxies, ["overhead", "compute time"], loc=2)
        
        # save plot
        # plt.show()
        pdf.savefig()
        plt.close()
    
        
if __name__ == "__main__":

    # plot_inserts()
    # plot_query()
    # plot_update()
    plot_computable()
    print "Plotted :-)"
